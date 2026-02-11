module vduckdb

import v.vmod
import x.json2
import math
import time

pub struct DuckDB {
pub mut:
	db          &Database   = &Database{}
	conn        &Connection = &Connection{}
	result      &Result     = &Result{}
	num_rows    int
	num_columns int
	columns     map[string]string
	last_query  string
	file        string
	time_ms     string
	has_arrays  bool
}

@[params]
pub struct OutputConfig {
pub mut:
	max_rows  int    = 100   // -1 = all rows
	mode      string = 'box' // Other modes: 'box', 'ascii', 'md'
	delimiter string = ','
	with_type bool
}

// Generates a map of all fields returned by a query
fn build_columns_map(d DuckDB) map[string]string {
	mut columns := map[string]string{}
	for j in 0 .. d.num_columns {
		mut col_name := duckdb_column_name(d.result, j)
		mut col_type := duckdb_column_type(d.result, j).str()
		col_type = col_type.replace('duckdb_type_', '')
		columns[col_name] = col_type
	}
	return columns
}

// Check if result contains array or uuid columns that need casting
fn check_for_arrays(d DuckDB) bool {
	for _, col_type in d.columns {
		if col_type == 'array' || col_type == 'list' || col_type == 'uuid' {
			return true
		}
	}
	return false
}

// Rewrite query to CAST array/uuid columns to VARCHAR
fn rewrite_query_cast_arrays(q string, columns map[string]string) string {
	// Wrap array and uuid columns in CAST(col AS VARCHAR) with aliases to preserve column names
	mut modified_q := q
	
	// Find SELECT clause
	select_idx := modified_q.to_lower().index('select') or { return q }
	from_idx := modified_q.to_lower().index('from') or { return q }
	
	select_part := modified_q[select_idx + 6..from_idx].trim_space()
	from_part := modified_q[from_idx..]
	
	// Parse column list
	col_list := select_part.split(',')
	mut new_col_list := []string{}
	
	for col_expr in col_list {
		col_name := col_expr.trim_space()
		
		// Check if this column needs casting
		mut needs_cast := false
		for name, col_type in columns {
			if col_expr.contains(name) && (col_type == 'array' || col_type == 'list' || col_type == 'uuid') {
				needs_cast = true
				break
			}
		}
		
		if needs_cast {
			// Use alias to preserve original column name
			new_col_list << 'CAST(${col_name} AS VARCHAR) AS ${col_name}'
		} else {
			new_col_list << col_name
		}
	}
	
	modified_q = 'SELECT ' + new_col_list.join(', ') + ' ' + from_part
	return modified_q
}

// get_array builds an array of json2.Any maps containing the resulting data from the query.
// Each row is represented as a map with column names as keys and json2.Any values.
@[direct_array_access]
pub fn (d DuckDB) get_array() []map[string]json2.Any {
	mut col := ''
	mut arr := []map[string]json2.Any{}
	for r in 0 .. d.num_rows {
		mut row := map[string]json2.Any{}
		for idx, key in d.columns.keys() {
			col = d.columns[key]
			match col {
				'bool' {
					row[key] = json2.Any(duckdb_value_boolean(d.result, u64(idx), r))
				}
				'varchar' {
					row[key] = json2.Any(duckdb_value_string(d.result, u64(idx), r))
				}
				'blob' {
					row[key] = json2.Any(duckdb_value_string(d.result, u64(idx), r))
				}
				'bigint' {
					row[key] = json2.Any(duckdb_value_int64(d.result, u64(idx), r))
				}
				'integer' {
					row[key] = json2.Any(duckdb_value_int32(d.result, u64(idx), r))
				}
				'smallint' {
					row[key] = json2.Any(duckdb_value_int16(d.result, u64(idx), r))
				}
				'tinyint' {
					row[key] = json2.Any(duckdb_value_int8(d.result, u64(idx), r))
				}
				'hugeint' {
					row[key] = json2.Any(duckdb_hugeint_to_double(duckdb_value_hugeint(d.result,
						u64(idx), r)))
				}
				'float' {
					row[key] = json2.Any(duckdb_value_float(d.result, u64(idx), r))
				}
				'double' {
					row[key] = json2.Any(duckdb_value_double(d.result, u64(idx), r))
				}
				'decimal' {
					row[key] = json2.Any(duckdb_value_double(d.result, u64(idx), r))
				}
				'timestamp' {
					row[key] = json2.Any(json2.encode(duckdb_value_timestamp(d.result,
						u64(idx), r)))
				}
				'date' {
					row[key] = json2.Any(duckdb_value_date(d.result, u64(idx), r))
				}
				else {
					row[key] = json2.Any('')
				}
			}
		}
		arr << row
	}
	return arr
}

// get_array_as_string returns query results as an array of string maps.
// Each row is represented as a map with column names as keys and string values.
@[direct_array_access]
pub fn (d DuckDB) get_array_as_string() []map[string]string {
	mut arr := []map[string]string{}
	for r in 0 .. d.num_rows {
		mut row := map[string]string{}
		for idx, key in d.columns.keys() {
			// After rewriting, arrays are now VARCHAR, so just use duckdb_value_string
			row[key] = duckdb_value_string(d.result, u64(idx), r)
		}
		arr << row
	}
	return arr
}

// get_data_as_table returns query results formatted as an HTML table.
@[direct_array_access]
pub fn (d DuckDB) get_data_as_table() string {
	headers := '<tr>' + d.columns.keys().map('<th>' + it + '</th>').join_lines() + '</tr>'
	mut rows := []string{}
	for r in 0 .. d.num_rows {
		mut cells := []string{}
		for idx, _ in d.columns.keys() {
			cells << '<td>' + duckdb_value_string(d.result, u64(idx), r) + '</td>'
		}
		rows << '<tr>' + cells.join_lines() + '</tr>'
	}
	body := rows.join_lines()
	table := '<table><thead>${headers}</thead><tbody>${body}</tbody></table>'
	return table
}

@[params]
pub struct LimitOptions {
pub mut:
	n int = 100
}

// get_array_as_string_with_limit returns query results as string maps with a row limit.
// Use LimitOptions to specify the maximum number of rows to return (-1 for all rows).
@[direct_array_access]
pub fn (d DuckDB) get_array_as_string_with_limit(lo LimitOptions) []map[string]string {
	mut arr := []map[string]string{}
	num_rows := if lo.n > 0 { math.min(lo.n, d.num_rows) } else { d.num_rows }
	for r in 0 .. num_rows {
		mut row := map[string]string{}
		for idx, key in d.columns.keys() {
			row[key] = duckdb_value_string(d.result, u64(idx), r)
		}
		arr << row
	}
	return arr
}

// get_first_row returns the first row of query results as a string map.
// Returns an empty map if no results are available.
pub fn (d DuckDB) get_first_row() map[string]string {
	arr := d.get_array_as_string()
	if arr.len == 0 {
		return map[string]string{}
	}
	return arr[0]
}

// open opens and connects to a DuckDB database file.
// Use ':memory:' as filename for an in-memory database.
// Returns an error if the file is not found or cannot be accessed.
pub fn (mut d DuckDB) open(filename string) !State {
	mut res := duckdb_open(filename.str, d.db)
	if res == State.duckdberror {
		return error('Could not open "${filename}". Is it locked?')
	}
	res = duckdb_connect(d.db.db, d.conn)
	if res == State.duckdberror {
		return error('Could not connect to "${filename}"')
	}
	d.file = filename
	return res
}

// query executes a SQL query against the database.
// Automatically detects and handles array/uuid types by casting to VARCHAR.
// Returns State.duckdbsuccess on success or an error on failure.
pub fn (mut d DuckDB) query(q string) !State {
	/* if d.last_query.len > 0 {
		duckdb_destroy_result(d.result)
		d.result = &Result{}
	} */
	start_time := time.now()
	// First, execute with array types to check what we have
	mut res := duckdb_query(d.conn.conn, q.str, d.result)
	end_time := time.now()
	if res == State.duckdberror {
		msg := duckdb_query_error(d.result)
		return error(msg)
	} else {
		d.num_rows = int(duckdb_row_count(d.result))
		d.num_columns = int(duckdb_column_count(d.result))
		d.columns = build_columns_map(d)
		d.has_arrays = check_for_arrays(d)
		
		// If there are arrays, re-execute query with CAST to VARCHAR
		if d.has_arrays {
			duckdb_destroy_result(d.result)
			d.result = &Result{}
			
			modified_q := rewrite_query_cast_arrays(q, d.columns)
			res = duckdb_query(d.conn.conn, modified_q.str, d.result)
			if res == State.duckdberror {
				msg := duckdb_query_error(d.result)
				return error(msg)
			}
			d.num_rows = int(duckdb_row_count(d.result))
			d.columns = build_columns_map(d)
			}
			
			d.last_query = q
			d.time_ms = (end_time - start_time).str()
			return res
	}
	duckdb_destroy_result(d.result)
	return State.duckdberror
}

// dim returns the dimensions of the query result as (rows, columns).
pub fn (mut d DuckDB) dim() (int, int) {
	return d.num_rows, d.num_columns
}

// print_table formats query results as a table string.
// See OutputConfig for formatting options (mode, delimiter, max_rows, etc.).
pub fn (d DuckDB) print_table(o OutputConfig) string {
	limit := if o.max_rows < 0 {
		d.num_rows
	} else {
		math.min(d.num_rows, o.max_rows)
	}
	data := d.get_array_as_string()
	out := if o.mode == 'csv' {
		headers := data[0].keys().join(o.delimiter)
		rows := data[0..limit].map(it.values().join(o.delimiter)).join_lines()
		headers + '\n' + rows
	} else {
		gen_table(o, data, limit)
	}
	return out
}

// close closes the database connection and cleans up resources.
pub fn (mut d DuckDB) close() {
	// duckdb_destroy_result(d.result)
	duckdb_disconnect(d.conn)
	duckdb_close(d.db)
}

// version returns the current vduckdb version string.
pub fn version() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	return vm.version
}

module vduckdb

import v.vmod
import x.json2
import math

pub struct DuckDB {
pub mut:
	db          &Database   = &Database{}
	conn        &Connection = &Connection{}
	result      &Result     = &Result{}
	num_rows    int
	num_columns int
	columns     map[string]string
	last_query  string
}

@[params]
pub struct OutputConfig {
pub mut:
	max_rows  int    = 100 // -1 = all rows
	mode      string = 'box' // Other modes: 'box', 'ascii'
	with_type bool
}

// Generates a map of all fields returned by a query
fn build_columns_map(d DuckDB) map[string]string {
	mut columns := map[string]string{}
	for j in 0 .. d.num_columns {
		mut col_name := duckdb_column_name(d.result, j)
		mut col_type := duckdb_column_type(d.result, j).str()
		columns[col_name] = col_type.replace('duckdb_type_', '')
	}
	return columns
}

// Builds an array of json2.Any maps containing the resulting data from the query
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
					row[key] = json2.Any(duckdb_value_int16(d.result, u64(idx), r))
				}
				'smallint' {
					row[key] = json2.Any(duckdb_value_int16(d.result, u64(idx), r))
				}
				'hugeint' {
					row[key] = json2.Any(json2.encode(duckdb_value_hugeint(d.result, u64(idx),
						r)))
				}
				'float' {
					row[key] = json2.Any(duckdb_value_float(d.result, u64(idx), r))
				}
				'double' {
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

// Version that returns results as []map[string]string
@[direct_array_access]
pub fn (d DuckDB) get_array_as_string() []map[string]string {
	mut arr := []map[string]string{}
	for r in 0 .. d.num_rows {
		mut row := map[string]string
		for idx, key in d.columns.keys() {
			row[key] = duckdb_value_string(d.result, u64(idx), r)
		}
		arr << row
	}
	return arr
}

// Opens and connects to a database. Returns error if file is not found. To use in memory use ':memory:' as filename
pub fn (mut d DuckDB) open(filename string) !State {
	mut res := duckdb_open(filename.str, d.db)
	if res == State.duckdberror {
		return error('Could not open "${filename}". Is it locked?')
	} 
	res = duckdb_connect(d.db.db, d.conn)
	if res == State.duckdberror {
		return error('Could not connect to "${filename}"')
	}	
	return res
}

// Runs a query
pub fn (mut d DuckDB) query(q string) !State {
	if d.last_query.len > 0 {
		duckdb_destroy_result(d.result)
		d.result = &Result{}
	}
	res := duckdb_query(d.conn.conn, q.str, d.result)
	if res == State.duckdberror {
		msg := duckdb_query_error(d.result)
		return error(msg)
	} else {
		d.num_rows = int(duckdb_row_count(d.result))
		d.num_columns = int(duckdb_column_count(d.result))
		d.columns = build_columns_map(d)
		d.last_query = q
		return res
	}
	return State.duckdberror
}

// Returns a tuple of number of rows and number of columns
pub fn (mut d DuckDB) dim() (int, int) {
	return d.num_rows, d.num_columns
}

// Outputs the data as a table. Check `OutputConfig` for options
pub fn (d DuckDB) print_table(o OutputConfig) string {
	limit := if o.max_rows < 0 {
		d.num_rows
	} else {
		math.min(d.num_rows, o.max_rows)
	}
	data := d.get_array()
	out := gen_table(o, data, limit)
	return out
}

// Closes the connection, database, and destroys results
pub fn (mut d DuckDB) close() {
	duckdb_destroy_result(d.result)
	duckdb_disconnect(d.conn)
	duckdb_close(d.db)
}

// Returns current vduckdb version
pub fn version() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	return vm.version
}

module vduckdb

import v.vmod
import x.json2
import math

pub struct DuckDB {
pub mut:
	db 				&Database 	 = &Database{}
	conn			&Connection  = &Connection{}
	result			&Result		 = &Result{}
	num_rows		int
	num_columns 	int
	columns			map[string]string
	last_query		string
	data			[]map[string]json2.Any
}

[params]
pub struct OutputConfig {
pub mut:
    max_rows      	int = 20				// -1 = all rows
	mode			string = 'box' 			// Other modes: 'box', 'ascii'
	with_type		bool
}

// Generates a dictionary of all fields returned by a query 
fn (mut d DuckDB) build_columns_map() {
	for j in 0 .. d.num_columns {
		mut col_name := duckdb_column_name(d.result, j)
		mut col_type := duckdb_column_type(d.result, j).str()
		c := match col_type {
			'duckdb_type_boolean' { 'bool' }
			'duckdb_type_float'  { 'float' }
			'duckdb_type_varchar' { 'string' }
			'duckdb_type_date' { 'date' }
			'duckdb_type_bigint' { 'bigint' }
			else { col_type }
		}
		d.columns[col_name] = c
	}
}

// Builds an array of json maps containing the resulting data from the query
fn (mut d DuckDB) build_data() {
	mut arr := []map[string]json2.Any{}
	for r in 0 .. d.num_rows {
		mut row := map[string]json2.Any{}
		for idx, key in d.columns.keys() {
			match key {
				'string' { row[key] = json2.Any(duckdb_value_string(d.result, u64(idx), r)) }
				else { row[key] = json2.Any(duckdb_value_string(d.result, u64(idx), r)) }
			}
		}
		arr << row
	}	
	d.data = arr
}

// Opens and connects to a database. To use in memory use ':memory:' as filename
pub fn (mut d DuckDB) open(filename string) State {
	mut res := duckdb_open(filename.str, d.db)
	res = duckdb_connect(d.db.db, d.conn)
	return res
}

// Runs a query
pub fn (mut d DuckDB) query(sql string) State {
	res := duckdb_query(d.conn.conn, sql.str, d.result)
	d.num_rows = int(duckdb_row_count(d.result))
	d.num_columns = int(duckdb_column_count(d.result))
	d.build_columns_map()
	d.build_data()
	d.last_query = sql
	return res
}

// Returns a tuple of the number of rows and columns
pub fn (mut d DuckDB) dim() (int,int) {
	return d.num_rows, d.num_columns
}

// Outputs the data as a table. Check OutputConfig for options
pub fn (d DuckDB) data(o OutputConfig) string {
	limit := if o.max_rows < 0 {
		d.num_rows
	} else {
		math.min(d.num_rows, o.max_rows)
	}
	out := gen_table(o, d.data, limit) 
	return out
}

// Closes the connections, database and destroys results
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
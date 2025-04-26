module vduckdb

import x.json2

fn test__simple_query() {
	mut db := DuckDB{}
	mut res := db.open(':memory:')!
	q := 'SELECT 1 AS total'
	res = db.query(q)!
	assert res == State.duckdbsuccess
}

fn test__out_json2() {
	mut db := DuckDB{}
	mut res := db.open(':memory:')!
	q := 'SELECT 1 AS total'
	res = db.query(q)!
	data := db.get_array()
	assert typeof(data).name == '[]map[string]json2.Any'
}

fn test__out_data() {
	mut db := DuckDB{}
	mut res := db.open(':memory:')!
	q := "SELECT 'abc' AS total"
	res = db.query(q)!
	data := db.get_array()
	assert data == [{
		'total': json2.Any('abc')
	}]
}

fn test__out_data_string() {
	mut vdb := DuckDB{}
	_ := vdb.open(':memory:')!
	_ := vdb.query("select 1 as a")!
	res := vdb.get_array_as_string()
	assert res == [{
		'a': '1'
	}]
}

fn test__out_data_table() {
	mut vdb := DuckDB{}
	_ := vdb.open(':memory:')!
	_ := vdb.query("select 1 as a")!
	res := vdb.print_table()
	assert res.starts_with('┌───┐')
}

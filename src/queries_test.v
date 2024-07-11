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
	assert data == [{'total': json2.Any('abc')}] 
}

module vduckdb

fn test__simple_query() {
	mut db := DuckDB{}
	mut res := db.open(':memory:')
	res = db.connect()
	q := 'SELECT 1 AS total'
	res = db.query(q)
	assert res == State.duckdbsuccess
}

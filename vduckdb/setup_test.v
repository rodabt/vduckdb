module vduckdb

import os

fn test_create_db() {
	mut db := DuckDB{}
	mut res := db.open('file.db')
	assert res == State.duckdbsuccess
	os.rm('file.db')!
	os.rm('file.db.wal')!
}

fn test_connect_db() {
	mut db := DuckDB{}
	mut res := db.open(':memory:')
	res = db.connect()
	assert res == State.duckdbsuccess
}

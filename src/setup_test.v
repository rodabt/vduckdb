module vduckdb

import os

fn test_create_db() {
	mut db := DuckDB{}
	mut res := db.open('file.db')!
	assert res == State.duckdbsuccess
	os.rm('file.db') or {}
	os.rm('file.db.wal') or {}
}

fn test_connect_db() {
	mut db := DuckDB{}
	mut res := db.open(':memory:')!
	assert res == State.duckdbsuccess
}

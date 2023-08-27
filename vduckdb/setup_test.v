module vduckdb

import os

fn test_create_db() {
	db := &Database{}
	mut res := open(c'file.db', db)
	assert res == State.duckdbsuccess
	os.rm('file.db')!
	os.rm('file.db.wal')!
}

fn test_connect_db() {
	db := &Database{}
	conn := &Connection{}
	mut res := open(c':memory:', db)
	assert connect(db.db, conn) == State.duckdbsuccess
}

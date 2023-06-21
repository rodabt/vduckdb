module vduckdb

import os

fn test__create_db() {
	db := &vduckdb.Database{}
	mut res := vduckdb.open(c'file.db', db)
	assert  res == vduckdb.State.duckdbsuccess
	os.rm('file.db')!
	os.rm('file.db.wal')!
}

fn test__connect_db() {
	db := &vduckdb.Database{}
	conn := &vduckdb.Connection{}
	mut res := vduckdb.open(c':memory:', db)
	assert vduckdb.connect(db.db, conn) == vduckdb.State.duckdbsuccess
}
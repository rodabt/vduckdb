import vduckdb as duckdb 
import os


fn test__create_db() {
	db := &duckdb.Database{}
	mut res := duckdb.open(c'file.db', db)
	assert  res == duckdb.State.duckdbsuccess
	os.rm('file.db')!
	os.rm('file.db.wal')!
}

fn test__connect_db() {
	db := &duckdb.Database{}
	conn := &duckdb.Connection{}
	mut res := duckdb.open(c':memory:', db)
	assert duckdb.connect(db.db, conn) == duckdb.State.duckdbsuccess
}
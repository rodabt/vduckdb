import duckdb
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

fn test__simple_query() {
	db := &duckdb.Database{}
	conn := &duckdb.Connection{}
	result := &duckdb.Result{}
	mut res := duckdb.open(c':memory:', db)
	res = duckdb.connect(db.db, conn)
	query := "SELECT 1 AS total"
	res = duckdb.query(conn.conn, query.str, result)
	assert res == duckdb.State.duckdbsuccess
}
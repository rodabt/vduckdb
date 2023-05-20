module duckdb 

// #flag -I.
// #include "duckdb.h"
#flag -L.
#flag -lduckdb

pub struct Database {
	pub: db voidptr
}

pub struct Connection {
	pub: conn voidptr
}

pub struct Results {
	pub: results voidptr
}

pub enum State {
	duckdbsuccess = 0	
	duckdberror = 1
}

fn C.duckdb_open(path &char, database &Database) State
fn C.duckdb_connect(database &Database, connection &Connection) State
fn C.duckdb_query(connection &Connection, query &char, results &Results) State
fn C.duckdb_disconnect(connection &Connection)
fn C.duckdb_close(database &Database)
fn C.duckdb_library_version() &char
fn C.duckdb_destroy_result(results &Results)
fn C.duckdb_row_count(results &Results) u64
fn C.duckdb_column_count(results &Results) u64


pub fn open(path &char, database &Database) State {
	return C.duckdb_open(path, database)
}

pub fn connect(database &Database, connection &Connection) State {
	return C.duckdb_connect(database, connection)
}

pub fn query(connection &Connection, query &char, results &Results) State {
	return C.duckdb_query(connection, query, results)
}

pub fn disconnect(connection &Connection) {
	C.duckdb_disconnect(connection)
}

pub fn close(database &Database) {
	C.duckdb_close(database)
}

pub fn library_version() &char {
	return C.duckdb_library_version()
}

pub fn destroy_result(results &Results) {
	C.duckdb_destroy_result(results)
}

pub fn row_count(results &Results) u64 {
	return C.duckdb_row_count(results)
}

pub fn column_count(results &Results) u64 {
	return C.duckdb_column_count(results)
}
#flag -I.
#flag -L.
#include "duckdb.h"
#flag -lduckdb

struct Duckdb_database {
	db voidptr
}

struct Duckdb_connection {
	conn voidptr
}

struct Duckdb_results {
	results voidptr
}

enum Duckdb_state {
	duckdbsuccess = 0	
	duckdberror = 1
}

fn C.duckdb_open(path &char, database &Duckdb_database) Duckdb_state
fn C.duckdb_connect(database voidptr, connection &Duckdb_connection) Duckdb_state
fn C.duckdb_query(connection voidptr, query &char, results &Duckdb_results) Duckdb_state
fn C.duckdb_disconnect(connection voidptr)
fn C.duckdb_close(database voidptr)
fn C.duckdb_library_version() &char
fn C.duckdb_destroy_result(results voidptr)

// DUCKDB_API void duckdb_disconnect(duckdb_connection *connection);


pub fn duckdb_open(path &char, database &Duckdb_database) Duckdb_state {
	return C.duckdb_open(path, database)
}

pub fn duckdb_connect(database voidptr, connection &Duckdb_connection) Duckdb_state {
	return C.duckdb_connect(database, connection)
}

pub fn duckdb_query(connection voidptr, query &char, results &Duckdb_results) Duckdb_state {
	return C.duckdb_query(connection, query, results)
}

pub fn duckdb_disconnect(connection voidptr) {
	C.duckdb_disconnect(connection)
}

pub fn duckdb_close(database voidptr) {
	C.duckdb_close(database)
}

pub fn duckdb_library_version() &char {
	return C.duckdb_library_version()
}

pub fn duckdb_destroy_result(results voidptr) {
	C.duckdb_destroy_result(results)
}

fn main() {
	// Before running: export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":.
	version := duckdb_library_version()
	println("Version: ${version}")
	db := &Duckdb_database{}
	conn := &Duckdb_connection{}
	results := &Duckdb_results{}
	res_open := duckdb_open(c'here.db', db)
	println("Open: ${res_open}")
	res_connect := duckdb_connect(db.db, conn)
	println("Connect: ${res_connect}")
	res_results := duckdb_query(conn.conn, c'create table test as select 1', results)
	println("Query: ${res_results}")
	duckdb_destroy_result(results)
	duckdb_disconnect(conn)
	duckdb_close(db)
}
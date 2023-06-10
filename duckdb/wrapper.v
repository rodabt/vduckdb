// Copyright (c) 2023 Rodrigo Abt. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module duckdb

// #flag -L.
#flag -lduckdb

pub struct Database {
pub:
	db voidptr
}

pub struct Connection {
pub:
	conn voidptr
}

pub enum Type {
	duckdb_type_invalid = 0
	duckdb_type_boolean
	duckdb_type_tinyint
	duckdb_type_smallint
	duckdb_type_integer
	duckdb_type_bigint
	duckdb_type_utinyint
	duckdb_type_usmallint
	duckdb_type_uinteger
	duckdb_type_ubigint
	duckdb_type_float
	duckdb_type_double
	duckdb_type_timestamp
	duckdb_type_date
	duckdb_type_time
	duckdb_type_interval
	duckdb_type_hugeint
	duckdb_type_varchar
	duckdb_type_blob
	duckdb_type_decimal
	duckdb_type_timestamp_s
	duckdb_type_timestamp_ms
	duckdb_type_timestamp_ns
	duckdb_type_enum
	duckdb_type_list
	duckdb_type_struct
	duckdb_type_map
	duckdb_type_uuid
	duckdb_type_union
	duckdb_type_bit
}

pub struct Column {
pub:
	deprecated_data     ?voidptr
	deprecated_nullmask ?bool
	deprecated_type     ?Type
	deprecated_name     ?&char
	internal_data       voidptr
}

pub struct Result {
pub:
	deprecated_column_count  ?int
	deprecated_row_count     ?int
	deprecated_rows_changed  ?int
	deprecated_columns       ?&Column
	deprecated_error_message ?&char
	internal_data            voidptr
}

pub struct Arrow {
pub:
	arrw voidptr
}

pub enum State {
	duckdbsuccess = 0
	duckdberror = 1
}

pub struct Data_chunk {
pub:
	dtck voidptr
}

pub struct Vector {
pub:
	vctr voidptr
}

pub struct String {
pub:
	data string
	size u64
}

/*
* OPEN and CONNECTION
*/

fn C.duckdb_open(path &char, database &Database) State

// Opens a new database file. For in memory user `:memory:` as path
pub fn open(path &char, database &Database) State {
	return C.duckdb_open(path, database)
}

fn C.duckdb_connect(database &Database, connection &Connection) State

// Defines a new connection for a database
pub fn connect(database &Database, connection &Connection) State {
	return C.duckdb_connect(database, connection)
}

fn C.duckdb_disconnect(connection &Connection)

// Disconnects from database
pub fn disconnect(connection &Connection) {
	C.duckdb_disconnect(connection)
}

fn C.duckdb_close(database &Database)

// Closes database
pub fn close(database &Database) {
	C.duckdb_close(database)
}

/*
* QUERY AND RESULTS
*/

fn C.duckdb_query(connection &Connection, query &char, result &Result) State
pub fn query(connection &Connection, query &char, result &Result) State {
	return C.duckdb_query(connection, query, result)
}

fn C.duckdb_row_count(result &Result) u64
pub fn row_count(result &Result) u64 {
	return C.duckdb_row_count(result)
}

fn C.duckdb_column_count(result &Result) u64
pub fn column_count(result &Result) u64 {
	return C.duckdb_column_count(result)
}

fn C.duckdb_column_name(result &Result, col_idx u64) &char
pub fn column_name(result &Result, col_idx u64) &char {
	return C.duckdb_column_name(result, col_idx)
}

fn C.duckdb_destroy_result(result &Result)
pub fn destroy_result(result &Result) {
	C.duckdb_destroy_result(result)
}

fn C.duckdb_result_chunk_count(result Result) u64
pub fn result_chunk_count(result Result) u64 {
	return C.duckdb_result_chunk_count(result)
}

fn C.duckdb_result_get_chunk(result Result, chunk_index u64) &Data_chunk
pub fn result_get_chunk(result Result, chunk_index u64) &Data_chunk {
	return C.duckdb_result_get_chunk(result, chunk_index)
}

fn C.duckdb_data_chunk_get_vector(chunk &Data_chunk, col_idx u64) &Vector
pub fn data_chunk_get_vector(chunk &Data_chunk, col_idx u64) &Vector {
	return C.duckdb_data_chunk_get_vector(chunk, col_idx)
}

// DEPRECATED:
fn C.duckdb_value_varchar(result &Result, col u64, row u64) &char
pub fn value_varchar(result &Result, col u64, row u64) &char {
	return C.duckdb_value_varchar(result, col, row)
}

/*
* ARROW
*/

fn C.duckdb_query_arrow(connection &Connection, query &char, result &Arrow) State
pub fn query_arrow(connection &Connection, query &char, result &Arrow) State {
	return C.duckdb_query_arrow(connection, query, result)
}

fn C.duckdb_destroy_arrow(result &Arrow)
pub fn destroy_arrow(result &Arrow) {
	C.duckdb_destroy_arrow(result)
}

/*
* METADATA
*/

fn C.duckdb_library_version() &char
pub fn library_version() &char {
	return C.duckdb_library_version()
}

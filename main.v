#flag -I.
#flag -L.
#include "duckdb.h"
#flag -lduckdb

struct Duckdb_database {
	db voidptr
}

enum Duckdb_state {
	duckdbsuccess = 0	
	duckdberror = 1
}

fn C.duckdb_open(path &i8, out_database &Duckdb_database) Duckdb_state

pub fn duckdb_open(path &i8, out_database &Duckdb_database) Duckdb_state {
	return C.duckdb_open(path, out_database)
}

fn main() {
	// Before running: export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":.
	db := Duckdb_database{}
	duckdb_open(c'here.db', db)
}
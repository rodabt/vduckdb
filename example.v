import duckdb

// Before running make sure libduckdb in your the path
// Linux example: export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":/path/to/libduckdb.so library (Linux)

fn main() {
	// Define types
	db := &duckdb.Database{}
	conn := &duckdb.Connection{}
	result := &duckdb.Result{}
	arrow_result := &duckdb.Arrow{}

	file := ':memory:'
	res_open := duckdb.open(file.str, db)
	println('Open DB in ${file}, state: ${res_open}')

	res_connect := duckdb.connect(db.db, conn)
	println('Connect to DB, state: ${res_connect}')

	println("---------------")
	query := "select id as val, id*100 as nval from range(10) tbl(id)"
	println("Query: ${query}")
	mut res := duckdb.query(conn.conn, 
		query.str,
		result)
	println("Query state: ${res}")

	num_rows := duckdb.row_count(result)
	num_columns := duckdb.column_count(result)

	println("")
	println("Data: ")
	for r in 0 .. num_rows {
		for c in 0 .. num_columns {
			print(unsafe { duckdb.value_varchar(result, c, r).vstring() })
			print(" ")
		}
		println("")
	}
	println('Row count: ${num_rows}')
	println('Column count: ${num_columns}')

	// Terminate
	duckdb.destroy_arrow(arrow_result)
	duckdb.destroy_result(result)
	duckdb.disconnect(conn)
	duckdb.close(db)
}

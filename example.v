import duckdb

// Before running make sure libduckdb in your the path
// Linux example: export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":/path/to/libduckdb.so library (Linux)

fn main() {
	// Define types
	db := &duckdb.Database{}
	conn := &duckdb.Connection{}
	result := &duckdb.Result{}
	arrow_result := &duckdb.Arrow{}

	res_open := duckdb.open(c':memory:', db)
	println('Open: ${res_open}')

	res_connect := duckdb.connect(db.db, conn)
	println('Connect: ${res_connect}')

	mut res := duckdb.query(conn.conn, 
		c"select id as val, id*100 as nval from range(10) tbl(id)",
		result)
	println("Query: ${res}")

	res = duckdb.query_arrow(conn.conn, 
		c'select id, id*100 as val from range(10) tbl(id)', 
		arrow_result)
	println("Query Arrow: ${res}")

	num_rows := duckdb.row_count(result)
	println('Row count: ${num_rows}')

	num_columns := duckdb.column_count(result)
	println('Column count: ${num_columns}')

	prinln("Data: ")
	for r in 0 .. num_rows {
		for c in 0 .. num_columns {
			print(unsafe { duckdb.value_varchar(result, c, r).vstring() })
			print(" ")
		}
		println("")
	}

	// Terminate
	duckdb.destroy_arrow(arrow_result)
	duckdb.destroy_result(result)
	duckdb.disconnect(conn)
	duckdb.close(db)
}

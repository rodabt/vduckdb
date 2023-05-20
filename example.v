import duckdb

// Before running make sure libduckdb in your the path
// Linux example: export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}":/path/to/libduckdb.so library (Linux)

fn main() {
	// Define types
	db := &duckdb.Database{}
	conn := &duckdb.Connection{}
	results := &duckdb.Results{}

	res_open := duckdb.open(c':memory:', db)   // or file.db
	println('Open: ${res_open}')

	res_connect := duckdb.connect(db.db, conn)
	println('Connect: ${res_connect}')

	res_results := duckdb.query(conn.conn, c'select id, id*100 as val from range(10) tbl(id)',
		results)
	println('Query: ${res_results}')

	num_rows := duckdb.row_count(results)
	println('Row count: ${num_rows}')

	num_columns := duckdb.column_count(results)
	println('Column count: ${num_columns}')

	// Terminate
	duckdb.destroy_result(results)
	duckdb.disconnect(conn)
	duckdb.close(db)
}

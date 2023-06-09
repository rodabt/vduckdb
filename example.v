import rodabt.vduck.duckdb


fn main() {
	// Define types
	db := &duckdb.Database{}
	conn := &duckdb.Connection{}
	result := &duckdb.Result{}

	println("\nvduck version: ${duckdb.vduck_version()}")

	file := ':memory:'
	mut res := duckdb.open(file.str, db)

	if res == duckdb.State.duckdberror {
		println('Error opening DB ${file}: ${res}')
	}

	res = duckdb.connect(db.db, conn)

	if res == duckdb.State.duckdberror {
		println('Error connecting to DB: ${res}')
	}

	query := "with data as (select id+10 as x, id*250 as y, 'test' as zzz from range(10) tbl(id)) select * from data"
	println("Query:\n${query}\n")
	
	res = duckdb.query(conn.conn, query.str, result)
	
	if res == duckdb.State.duckdberror {
		println('Error executing query: ${res}')
	}	

	num_rows := duckdb.row_count(result)
	num_columns := duckdb.column_count(result)

	mut arr := [][]string{len: int(num_rows), init: []string{len: int(num_columns)}}
	for r in 0 .. num_rows {
		for c in 0 .. num_columns {
			arr[r][c] = unsafe { duckdb.value_varchar(result, c, r).vstring() }
		}
	}

	mut column_names := []string{len: int(num_columns), init:''}
	for index, _ in column_names {
		column_names[index] = unsafe { duckdb.column_name(result, u64(index)).vstring() }
	}

	duckdb.print_table(arr, column_names)
	println('Row count: ${num_rows}')
	println('Column count: ${num_columns}')

	// Terminate
	duckdb.destroy_result(result)
	duckdb.disconnect(conn)
	duckdb.close(db)
}

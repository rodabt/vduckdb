import duckdb
import termtable


fn main() {
	// Define types
	db := &duckdb.Database{}
	conn := &duckdb.Connection{}
	result := &duckdb.Result{}

	println("\nvduck version: ${duckdb.vduck_version()}\n")

	file := ':memory:'
	mut res := duckdb.open(file.str, db)

	if res == duckdb.State.duckdberror {
		println('Error opening DB ${file}: ${res}')
	}

	res = duckdb.connect(db.db, conn)

	if res == duckdb.State.duckdberror {
		println('Error connecting to DB: ${res}')
	}

	query := "select * from 'people100.csv' limit 10"
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
			arr[r][c] = duckdb.value_string(result, c, r)
		}
	}

	println("\nColumns info:")
	mut arr_columns := []string{}
	for j in 0 .. num_columns {
		mut col_name := duckdb.column_name(result, j) 
		mut col_type := duckdb.column_type(result, j).str()
		println("Name: '${col_name}' - V Type: (${col_type})")
		arr_columns << col_name
	}
	arr.prepend(arr_columns)

	println("\nSample data:")
	table := termtable.Table{
		data: arr
		style: .fancy_grid
		header_style: .bold
		align: .left
		orientation: .row
		padding: 1
		tabsize: 4		
	}
	println(table)
	defer {
		duckdb.destroy_result(result)
		duckdb.disconnect(conn)
		duckdb.close(db)
	}
}

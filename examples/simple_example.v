import vduckdb
import termtable

fn main() {
	// Define types
	db := &vduckdb.Database{}
	conn := &vduckdb.Connection{}
	result := &vduckdb.Result{}

	println('\nvduckdb version: ${vduckdb.version()}\n')

	file := ':memory:'
	mut res := vduckdb.open(file.str, db)

	if res == vduckdb.State.duckdberror {
		println('Error opening DB ${file}: ${res}')
	}

	res = vduckdb.connect(db.db, conn)

	if res == vduckdb.State.duckdberror {
		println('Error connecting to DB: ${res}')
	}

	query := "select * from 'people100.csv' limit 10"
	println('Query:\n${query}\n')

	res = vduckdb.query(conn.conn, query.str, result)

	if res == vduckdb.State.duckdberror {
		println('Error executing query: ${res}')
	}

	num_rows := vduckdb.row_count(result)
	num_columns := vduckdb.column_count(result)

	mut arr := [][]string{len: int(num_rows), init: []string{len: int(num_columns)}}
	for r in 0 .. num_rows {
		for c in 0 .. num_columns {
			arr[r][c] = vduckdb.value_string(result, c, r)
		}
	}

	println('\nColumns info:')
	mut arr_columns := []string{}
	for j in 0 .. num_columns {
		mut col_name := vduckdb.column_name(result, j)
		mut col_type := vduckdb.column_type(result, j).str()
		println("Name: '${col_name}' - V Type: (${col_type})")
		arr_columns << col_name
	}
	arr.prepend(arr_columns)

	println('\nSample data:')
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
		vduckdb.destroy_result(result)
		vduckdb.disconnect(conn)
		vduckdb.close(db)
	}
}

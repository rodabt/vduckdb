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

	query := "
	-- This is a comment
	with data as (
		select 
			id+10 as x, 
			id*250 as y, 
			'test' as zzz 
		from range(10) tbl(id)
	) select * from data
	"
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
			if r == 0 { 
				arr[r][c] = unsafe { duckdb.column_name(result, u64(c)).vstring() } 
			} else { 
				arr[r][c] = unsafe { duckdb.value_varchar(result, c, r).vstring() } 
			}
		}
	}

	println("\nColumns info:")
	mut v_type := ''
	for j in 0 .. num_columns {
		mut col_name := unsafe { duckdb.column_name(result, u64(j)).vstring() } 
		mut col_type := duckdb.column_type(result, u64(j))
		match col_type {
			.duckdb_type_varchar {
				v_type = 'varchar'
			}
			.duckdb_type_bigint {
				v_type = 'i64'
			}
			else {
				v_type = 'other'
			}
		} 
		println("Name: '${col_name}' - V type: (${v_type})")
	}

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

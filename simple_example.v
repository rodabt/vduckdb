import vduckdb
// import termtable

fn main() {
	mut v := vduckdb.DuckDB{}

	println('\nvduckdb version: ${vduckdb.version()}\n')

	file := ':memory:'
	mut res := v.open(file)

	if res == vduckdb.State.duckdberror {
		println('Error opening DB ${file}: ${res}')
	}

	sql := "select * from 'people-100.csv'"
	println('Query:\n${sql}\n')

	res = v.query(sql)

	if res == vduckdb.State.duckdberror {
		println('Error executing query: ${res}')
	}

	println(v.columns)

	println(v.data(max_rows: -1, mode: 'box'))

	defer {
		v.close()
	}

}
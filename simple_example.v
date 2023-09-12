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

	q := "select Index, Email, \"Date of birth\" from 'people-100.csv'"
	println('Query:\n${q}\n')

	res = v.query(q) or { panic(err) }

	if res == vduckdb.State.duckdberror {
		println('Error executing query: ${res}')
	}

	println(v.columns)

	println(v.data(max_rows: 10, mode: 'box'))

	defer {
		v.close()
	}

}
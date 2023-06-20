module vduckdb

pub fn print_version() {
	version := vduckdb.version()
	println(version)
}
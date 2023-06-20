module vduckdb

pub fn print_version() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	println(vm.version)
}

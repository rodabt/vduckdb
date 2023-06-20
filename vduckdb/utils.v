module vduckdb

import v.vmod

pub fn vduckdb_version() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	return vm.version
}

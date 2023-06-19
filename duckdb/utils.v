module duckdb

import v.vmod

pub fn vduck_version() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	return vm.version
}

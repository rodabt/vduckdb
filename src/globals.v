module vduckdb

import dl
import time
import os

fn get_libname() !string {
	// Check current directory first
	if os.is_file(dl.get_libname('./libduckdb')) {
		return dl.get_libname('./libduckdb')
	}
	// Check environment variable
	if os.is_file(dl.get_libname('${os.getenv('LIBDUCKDB_DIR')}/libduckdb')) {
		return dl.get_libname('${os.getenv('LIBDUCKDB_DIR')}/libduckdb')
	}
	return error('')
}

const library_file_path = get_libname() or {
	println('[ERROR]: No libduckdb library installed. Set LIBDUCKDB_DIR env var to the directory containing libduckdb or put libduckdb in the current directory')
	exit(1)
}
const start_date = time.Time{
	year:  1970
	month: 1
	day:   1
}

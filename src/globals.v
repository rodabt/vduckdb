module vduckdb

import dl
import time
import os

fn get_libname() string {
	libname:= if os.getenv('LIBDUCKDB_DIR') == '' {
		dl.get_libname('thirdparty/libduckdb')
	} else {
		dl.get_libname('${os.getenv('LIBDUCKDB_DIR')}/libduckdb')
	}
	return libname
}

const library_file_path = get_libname()
const start_date = time.Time{
	year:  1970
	month: 1
	day:   1
}

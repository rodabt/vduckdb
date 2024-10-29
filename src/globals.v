module vduckdb

import dl
import time
import os

const library_file_path = if os.getenv('LIBDUCKDB_DIR')=='' { dl.get_libname('thirdparty/libduckdb') } else {
	dl.get_libname("${os.getenv('LIBDUCKDB_DIR')}/libduckdb")
}
const start_date = time.Time{
	year:  1970
	month: 1
	day:   1
}

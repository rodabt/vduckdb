module vduckdb

import dl
import os
import time

const library_file_path = os.join_path(os.dir(@FILE), dl.get_libname('thirdparty/libduckdb'))
const start_date = time.Time{
	year: 1970
	month: 1
	day: 1
} 
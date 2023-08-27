module vduckdb 

import dl
import os

const library_file_path = os.join_path(os.dir(@FILE), dl.get_libname('lib/libduckdb'))
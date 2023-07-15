module vduckdb

import os
import dl
import v.vmod

pub struct Database {
pub:
	db voidptr
}

pub struct Connection {
pub:
	conn voidptr
}

pub enum Type {
	duckdb_type_invalid = 0
	duckdb_type_boolean
	duckdb_type_tinyint
	duckdb_type_smallint
	duckdb_type_integer
	duckdb_type_bigint
	duckdb_type_utinyint
	duckdb_type_usmallint
	duckdb_type_uinteger
	duckdb_type_ubigint
	duckdb_type_float
	duckdb_type_double
	duckdb_type_timestamp
	duckdb_type_date
	duckdb_type_time
	duckdb_type_interval
	duckdb_type_hugeint
	duckdb_type_varchar
	duckdb_type_blob
	duckdb_type_decimal
	duckdb_type_timestamp_s
	duckdb_type_timestamp_ms
	duckdb_type_timestamp_ns
	duckdb_type_enum
	duckdb_type_list
	duckdb_type_struct
	duckdb_type_map
	duckdb_type_uuid
	duckdb_type_union
	duckdb_type_bit
}

pub struct Column {
pub:
	deprecated_data     ?voidptr
	deprecated_nullmask ?bool
	deprecated_type     ?Type
	deprecated_name     ?&char
	internal_data       voidptr
}

pub struct Result {
pub:
	deprecated_column_count  ?int
	deprecated_row_count     ?int
	deprecated_rows_changed  ?int
	deprecated_columns       ?&Column
	deprecated_error_message ?&char
	internal_data            voidptr
}

pub enum State {
	duckdbsuccess = 0
	duckdberror = 1
}

pub struct String {
pub:
	data string
	size u64
}

type FNOpen = fn (&char, &Database) State

type FNConnect = fn (&Database, &Connection) State

type FNDisconnect = fn (&Connection)

type FNClose = fn (&Database)

type FNQuery = fn (&Connection, &char, &Result) State

type FNCount = fn (&Result) u64

type FNColName = fn (&Result, u64) &char

type FNColType = fn (&Result, u64) Type

type FNDestroyRes = fn (&Result)

type FNValueBoolean = fn (&Result, u64, u64) bool

type FNValueInt8 = fn (&Result, u64, u64) i8

type FNValueInt16 = fn (&Result, u64, u64) i16

type FNValueInt32 = fn (&Result, u64, u64) i32

type FNValueInt64 = fn (&Result, u64, u64) i64

type FNValueFloat = fn (&Result, u64, u64) f32

type FNValueDouble = fn (&Result, u64, u64) f64

type FNValueVarchar = fn (&Result, u64, u64) &char

const (
	library_file_path     = os.join_path(os.dir(@FILE), dl.get_libname('lib/libduckdb'))
	handle                = dl.open_opt(library_file_path, dl.rtld_lazy) or { panic(err) }
	duckdb_open           = FNOpen(dl.sym_opt(handle, 'duckdb_open') or { panic(err) })
	duckdb_connect        = FNConnect(dl.sym_opt(handle, 'duckdb_connect') or { panic(err) })
	duckdb_disconnect     = FNDisconnect(dl.sym_opt(handle, 'duckdb_disconnect') or { panic(err) })
	duckdb_close          = FNClose(dl.sym_opt(handle, 'duckdb_close') or { panic(err) })
	duckdb_query          = FNQuery(dl.sym_opt(handle, 'duckdb_query') or { panic(err) })
	duckdb_row_count      = FNCount(dl.sym_opt(handle, 'duckdb_row_count') or { panic(err) })
	duckdb_column_count   = FNCount(dl.sym_opt(handle, 'duckdb_column_count') or { panic(err) })
	duckdb_column_chars   = FNColName(dl.sym_opt(handle, 'duckdb_column_name') or { panic(err) })
	duckdb_column_type    = FNColType(dl.sym_opt(handle, 'duckdb_column_type') or { panic(err) })
	duckdb_destroy_result = FNDestroyRes(dl.sym_opt(handle, 'duckdb_destroy_result') or {
		panic(err)
	})
	duckdb_value_boolean  = FNValueBoolean(dl.sym_opt(handle, 'duckdb_value_boolean') or {
		panic(err)
	})
	duckdb_value_int8     = FNValueInt8(dl.sym_opt(handle, 'duckdb_value_int8') or { panic(err) })
	duckdb_value_int16    = FNValueInt16(dl.sym_opt(handle, 'duckdb_value_int16') or { panic(err) })
	duckdb_value_int32    = FNValueInt32(dl.sym_opt(handle, 'duckdb_value_int32') or { panic(err) })
	duckdb_value_int64    = FNValueInt64(dl.sym_opt(handle, 'duckdb_value_int64') or { panic(err) })
	duckdb_value_float    = FNValueFloat(dl.sym_opt(handle, 'duckdb_value_float') or { panic(err) })
	duckdb_value_double   = FNValueDouble(dl.sym_opt(handle, 'duckdb_value_double') or {
		panic(err)
	})
	duckdb_value_varchar  = FNValueVarchar(dl.sym_opt(handle, 'duckdb_value_varchar') or {
		panic(err)
	})
)

pub fn duckdb_value_string(result &Result, col u64, row u64) string {
	ret := unsafe { duckdb_value_varchar(result, col, row).vstring() }
	return ret
}

pub fn duckdb_column_name(result &Result, col_idx u64) string {
	ret := unsafe { duckdb_column_chars(result, col_idx).vstring() }
	return ret
}

pub fn version() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	return vm.version
}
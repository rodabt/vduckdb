module vduckdb

import dl

struct Database {
pub:
	db voidptr
}

struct Connection {
pub:
	conn voidptr
}

enum Type {
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

struct Column {
pub:
	deprecated_data     ?voidptr
	deprecated_nullmask ?bool
	deprecated_type     ?Type
	deprecated_name     ?&char
	internal_data       voidptr
}

struct Result {
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
	duckdberror   = 1
}

struct String {
pub:
	data &char
	size u64
}

struct HugeInt {
pub:
	lower u64
	upper i64
}

struct Decimal {
pub:
	width u8
	scale u8
	value HugeInt
}

struct Date {
pub:
	days i32
}

struct Time {
pub:
	micros i64
}

struct Interval {
pub:
	months i32
	days   i32
	micros i64
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

type FNValueHugeInt = fn (&Result, u64, u64) HugeInt

type FNValueDecimal = fn (&Result, u64, u64) Decimal

type FNValueHugeIntToDouble = fn (HugeInt) f64

type FNValueDate = fn (&Result, u64, u64) Date

type FNValueTime = fn (&Result, u64, u64) Time

type FNValueTimestamp = fn (&Result, u64, u64) Time

type FNValueInterval = fn (&Result, u64, u64) Interval

type FNValueString = fn (&Result, u64, u64) String

type FNResultError = fn (&Result) &char

type FNVoidPtr = fn (voidptr)

type FNVersion = fn () &char

const handle = dl.open_opt(library_file_path, dl.rtld_lazy) or { panic(err) }
const duckdb_open = FNOpen(dl.sym_opt(handle, 'duckdb_open') or { panic(err) })
const duckdb_connect = FNConnect(dl.sym_opt(handle, 'duckdb_connect') or { panic(err) })
const duckdb_disconnect = FNDisconnect(dl.sym_opt(handle, 'duckdb_disconnect') or { panic(err) })
const duckdb_close = FNClose(dl.sym_opt(handle, 'duckdb_close') or { panic(err) })
const duckdb_query = FNQuery(dl.sym_opt(handle, 'duckdb_query') or { panic(err) })
const duckdb_row_count = FNCount(dl.sym_opt(handle, 'duckdb_row_count') or { panic(err) })
const duckdb_column_count = FNCount(dl.sym_opt(handle, 'duckdb_column_count') or { panic(err) })
const duckdb_column_chars = FNColName(dl.sym_opt(handle, 'duckdb_column_name') or { panic(err) })
const duckdb_column_type = FNColType(dl.sym_opt(handle, 'duckdb_column_type') or { panic(err) })
const duckdb_destroy_result = FNDestroyRes(dl.sym_opt(handle, 'duckdb_destroy_result') or {
	panic(err)
})
// Returning values
const duckdb_value_boolean = FNValueBoolean(dl.sym_opt(handle, 'duckdb_value_boolean') or {
	panic(err)
})
const duckdb_value_int8 = FNValueInt8(dl.sym_opt(handle, 'duckdb_value_int8') or { panic(err) })
const duckdb_value_int16 = FNValueInt16(dl.sym_opt(handle, 'duckdb_value_int16') or { panic(err) })
const duckdb_value_int32 = FNValueInt32(dl.sym_opt(handle, 'duckdb_value_int32') or { panic(err) })
const duckdb_value_int64 = FNValueInt64(dl.sym_opt(handle, 'duckdb_value_int64') or { panic(err) })
const duckdb_value_float = FNValueFloat(dl.sym_opt(handle, 'duckdb_value_float') or { panic(err) })
const duckdb_value_double = FNValueDouble(dl.sym_opt(handle, 'duckdb_value_double') or {
	panic(err)
})
const duckdb_value_varchar = FNValueVarchar(dl.sym_opt(handle, 'duckdb_value_varchar') or {
	panic(err)
})
const duckdb_value_str = FNValueString(dl.sym_opt(handle, 'duckdb_value_string') or { panic(err) })
const duckdb_value_hugeint = FNValueHugeInt(dl.sym_opt(handle, 'duckdb_value_hugeint') or {
	panic(err)
})
const duckdb_hugeint_to_double = FNValueHugeIntToDouble(dl.sym_opt(handle, 'duckdb_hugeint_to_double') or {
	panic(err)
})
const duckdb_value_decimal = FNValueDecimal(dl.sym_opt(handle, 'duckdb_value_decimal') or {
	panic(err)
})
const duckdb_value_dt = FNValueDate(dl.sym_opt(handle, 'duckdb_value_date') or { panic(err) })
const duckdb_value_time = FNValueTime(dl.sym_opt(handle, 'duckdb_value_time') or { panic(err) })
const duckdb_value_timestamp = FNValueTimestamp(dl.sym_opt(handle, 'duckdb_value_timestamp') or {
	panic(err)
})
const duckdb_value_interval = FNValueInterval(dl.sym_opt(handle, 'duckdb_value_interval') or {
	panic(err)
})
const duckdb_result_error = FNResultError(dl.sym_opt(handle, 'duckdb_result_error') or {
	panic(err)
})
const duckdb_free = FNVoidPtr(dl.sym_opt(handle, 'duckdb_free') or { panic(err) })
const duckdb_lib_version = FNVersion(dl.sym_opt(handle, 'duckdb_library_version') or { panic(err) })

// TODO: Check when row or col are out of bounds!!!
pub fn duckdb_value_string(result &Result, col u64, row u64) string {
	ret := unsafe { duckdb_value_varchar(result, col, row) }
	if ret == unsafe { nil } {
		return 'NULL'
	}
	s := unsafe { (*ret).vstring().clone() }
	duckdb_free(ret)
	return s
}

pub fn duckdb_value_date(result &Result, col u64, row u64) string {
	days := unsafe { duckdb_value_dt(result, col, row).days }
	cdate := start_date.add_days(days)
	return cdate.strftime('%Y-%m-%d')
}

pub fn duckdb_query_error(result &Result) string {
	ret := unsafe { duckdb_result_error(result).vstring() }
	return ret
}

pub fn duckdb_column_name(result &Result, col_idx u64) string {
	ret := unsafe { duckdb_column_chars(result, col_idx).vstring() }
	return ret
}

pub fn duckdb_library_version() string {
	ret := unsafe { duckdb_lib_version().vstring() }
	return ret
}

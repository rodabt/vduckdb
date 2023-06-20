import vduckdb as duckdb

fn test__simple_query() {
	db := &duckdb.Database{}
	conn := &duckdb.Connection{}
	result := &duckdb.Result{}
	mut res := duckdb.open(c':memory:', db)
	res = duckdb.connect(db.db, conn)
	query := "SELECT 1 AS total"
	res = duckdb.query(conn.conn, query.str, result)
	assert res == duckdb.State.duckdbsuccess
}

fn test__value_types() {
	db := &duckdb.Database{}
	conn := &duckdb.Connection{}
	result := &duckdb.Result{}
	mut res := duckdb.open(c':memory:', db)
	res = duckdb.connect(db.db, conn)
	query := "
	SELECT 
		1 AS v_int,
		1024 as v_int16,
		true AS v_bool,
		'text' as v_varchar
	"
	res = duckdb.query(conn.conn, query.str, result)
	assert res == duckdb.State.duckdbsuccess
	v_int8 := duckdb.value_int8(result, 0, 0)
	assert v_int8 == 1 
	v_int16 := duckdb.value_int16(result, 1, 0)
	assert v_int16 == 1024 
	v_bool := duckdb.value_boolean(result, 2, 0)
	assert v_bool == true
	v_string := duckdb.value_string(result, 3, 0)
	assert v_string == 'text'
}
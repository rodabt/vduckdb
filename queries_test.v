module vduckdb

fn test__simple_query() {
	db := &vduckdb.Database{}
	conn := &vduckdb.Connection{}
	result := &vduckdb.Result{}
	mut res := vduckdb.open(c':memory:', db)
	res = vduckdb.connect(db.db, conn)
	q := "SELECT 1 AS total"
	res = vduckdb.query(conn.conn, q.str, result)
	assert res == vduckdb.State.duckdbsuccess
}

fn test__value_types() {
	db := &vduckdb.Database{}
	conn := &vduckdb.Connection{}
	result := &vduckdb.Result{}
	mut res := vduckdb.open(c':memory:', db)
	res = vduckdb.connect(db.db, conn)
	q := "
	SELECT 
		1 AS v_int,
		1024 as v_int16,
		true AS v_bool,
		'text' as v_varchar
	"
	res = vduckdb.query(conn.conn, q.str, result)
	assert res == vduckdb.State.duckdbsuccess
	v_int8 := vduckdb.value_int8(result, 0, 0)
	assert v_int8 == 1 
	v_int16 := vduckdb.value_int16(result, 1, 0)
	assert v_int16 == 1024 
	v_bool := vduckdb.value_boolean(result, 2, 0)
	assert v_bool == true
	v_string := vduckdb.value_string(result, 3, 0)
	assert v_string == 'text'
}
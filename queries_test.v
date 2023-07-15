module vduckdb

fn test__simple_query() {
	db := &Database
	{
	}
	conn := &Connection
	{
	}
	result := &Result
	{
	}
	mut res := duckdb_open(c':memory:', db)
	res = duckdb_connect(db.db, conn)
	q := 'SELECT 1 AS total'
	res = duckdb_query(conn.conn, q.str, result)
	assert res == State.duckdbsuccess
}

fn test__no_result_query() {
	db := &Database
	{
	}
	conn := &Connection
	{
	}
	result := &Result
	{
	}
	mut res := duckdb_open(c':memory:', db)
	res = duckdb_connect(db.db, conn)
	q := 'CREATE TABLE test (id int)'
	res = duckdb_query(conn.conn, q.str, result)
	assert res == State.duckdbsuccess
}

fn test__value_types() {
	db := &Database
	{
	}
	conn := &Connection
	{
	}
	result := &Result
	{
	}
	mut res := duckdb_open(c':memory:', db)
	res = duckdb_connect(db.db, conn)
	q := "
	SELECT 
		1 AS v_int,
		1024 as v_int16,
		true AS v_bool,
		'text' as v_varchar
	"
	res = duckdb_query(conn.conn, q.str, result)
	assert res == State.duckdbsuccess
	v_int8 := duckdb_value_int8(result, 0, 0)
	assert v_int8 == 1
	v_int16 := duckdb_value_int16(result, 1, 0)
	assert v_int16 == 1024
	v_bool := duckdb_value_boolean(result, 2, 0)
	assert v_bool == true
	v_string := duckdb_value_string(result, 3, 0)
	assert v_string == 'text'
}

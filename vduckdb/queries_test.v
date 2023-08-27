module vduckdb

fn test__simple_query() {
	db := &Database{}
	conn := &Connection{}
	result := &Result{}
	mut res := open(c':memory:', db)
	res = connect(db.db, conn)
	q := 'SELECT 1 AS total'
	res = query(conn.conn, q.str, result)
	assert res == State.duckdbsuccess
}

fn test__no_result_query() {
	db := &Database{}
	conn := &Connection{}
	result := &Result{}
	mut res := open(c':memory:', db)
	res = connect(db.db, conn)
	q := 'CREATE TABLE test (id int)'
	res = query(conn.conn, q.str, result)
	assert res == State.duckdbsuccess
}

fn test__value_types() {
	db := &Database{}
	conn := &Connection{}
	result := &Result{}
	mut res := open(c':memory:', db)
	res = connect(db.db, conn)
	q := "
	SELECT 
		1 AS v_int,
		1024 as v_int16,
		true AS v_bool,
		'text' as v_varchar
	"
	res = query(conn.conn, q.str, result)
	assert res == State.duckdbsuccess
	v_int8 := value_int8(result, 0, 0)
	assert v_int8 == 1
	v_int16 := value_int16(result, 1, 0)
	assert v_int16 == 1024
	v_bool := value_boolean(result, 2, 0)
	assert v_bool == true
	v_string := value_string(result, 3, 0)
	assert v_string == 'text'
}

module vduckdb

import x.json2

fn test__simple_query() {
	mut db := DuckDB{}
	mut res := db.open(':memory:')!
	q := 'SELECT 1 AS total'
	res = db.query(q)!
	assert res == State.duckdbsuccess
}

fn test__out_json2() {
	mut db := DuckDB{}
	mut res := db.open(':memory:')!
	q := 'SELECT 1 AS total'
	res = db.query(q)!
	data := db.get_array()
	assert typeof(data).name == '[]map[string]json2.Any'
}

fn test__out_data() {
	mut db := DuckDB{}
	mut res := db.open(':memory:')!
	q := "SELECT 'abc' AS total"
	res = db.query(q)!
	data := db.get_array()
	assert data == [{
		'total': json2.Any('abc')
	}]
}

fn test__out_data_string() {
	mut vdb := DuckDB{}
	_ := vdb.open(':memory:')!
	_ := vdb.query('select 1 as a')!
	res := vdb.get_array_as_string()
	assert res == [{
		'a': '1'
	}]
}

fn test__out_data_table() {
	mut vdb := DuckDB{}
	_ := vdb.open(':memory:')!
	_ := vdb.query('select 1 as a')!
	res := vdb.print_table()
	assert res.starts_with('┌───┐')
}

fn test__array() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select x,y from tdata')!
	res := vdb.get_array_as_string()
	vdb.close()
	assert res[0]['x'] == "[1, 2, 3]"
}

fn test__uuid() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select id, name from test_uuid order by name')!
	res := vdb.get_array_as_string()
	vdb.close()
	assert res[0]['id'] == '550e8400-e29b-41d4-a716-446655440000'
	assert res[0]['name'] == 'alice'
	assert res[1]['id'] == '6ba7b810-9dad-11d1-80b4-00c04fd430c8'
	assert res[1]['name'] == 'bob'
}

fn test__uuid_json() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select id, name from test_uuid order by name limit 1')!
	res := vdb.get_array()
	vdb.close()
	id_val := res[0]['id'] or { json2.Any('') }
	name_val := res[0]['name'] or { json2.Any('') }
	assert id_val == json2.Any('550e8400-e29b-41d4-a716-446655440000')
	assert name_val == json2.Any('alice')
}

fn test__boolean() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select flag from test_bool order by id')!
	res := vdb.get_array_as_string()
	vdb.close()
	assert res[0]['flag'] == 'true'
	assert res[1]['flag'] == 'false'
	assert res[2]['flag'] == 'true'
}

fn test__boolean_json() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select flag from test_bool order by id limit 1')!
	res := vdb.get_array()
	vdb.close()
	// Verify boolean was retrieved
	flag_val := res[0]['flag'] or { json2.Any(json2.null) }
	assert flag_val != json2.Any(json2.null)
}

fn test__numeric_types() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select tiny_val, small_val, big_val, float_val, double_val from test_numeric')!
	res := vdb.get_array_as_string()
	vdb.close()
	assert res[0]['tiny_val'] == '10'
	assert res[0]['small_val'] == '100'
	assert res[0]['big_val'] == '1000000'
	assert res[0]['double_val'] == '3.14159'
}

fn test__numeric_json() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select tiny_val, small_val, big_val, double_val from test_numeric')!
	res := vdb.get_array()
	vdb.close()
	tiny := res[0]['tiny_val'] or { json2.Any(i8(0)) }
	small := res[0]['small_val'] or { json2.Any(i16(0)) }
	big := res[0]['big_val'] or { json2.Any(i64(0)) }
	double := res[0]['double_val'] or { json2.Any(0.0) }
	assert tiny == json2.Any(i8(10))
	assert small == json2.Any(i16(100))
	assert big == json2.Any(i64(1000000))
	assert double == json2.Any(3.14159)
}

fn test__decimal() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select amount from test_decimal order by id')!
	res := vdb.get_array_as_string()
	vdb.close()
	assert res[0]['amount'] == '123.45'
	assert res[1]['amount'] == '999.99'
}

fn test__decimal_json() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select amount from test_decimal limit 1')!
	res := vdb.get_array()
	vdb.close()
	// Decimal is converted to double
	amount := res[0]['amount'] or { json2.Any(0.0) }
	assert amount == json2.Any(123.45)
}

fn test__date() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select dt from test_date order by id')!
	res := vdb.get_array_as_string()
	vdb.close()
	assert res[0]['dt'] == '2024-01-15'
	assert res[1]['dt'] == '2024-12-25'
}

fn test__timestamp() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select ts from test_timestamp')!
	res := vdb.get_array_as_string()
	vdb.close()
	// Timestamp returns time structure, convert to string representation
	assert res[0]['ts'].len > 0
}

fn test__mixed_types() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select id, name, score, active from test_mixed order by id')!
	res := vdb.get_array_as_string()
	vdb.close()
	assert res[0]['id'] == '1'
	assert res[0]['name'] == 'alice'
	assert res[0]['active'] == 'true'
	assert res[1]['name'] == 'bob'
	assert res[1]['active'] == 'false'
}

fn test__mixed_types_json() {
	mut vdb := DuckDB{}
	_ := vdb.open('/home/rabt/devel/vduckdb/src/testdata/test.db')!
	_ := vdb.query('select id, name, score, active from test_mixed order by id limit 1')!
	res := vdb.get_array()
	vdb.close()
	name := res[0]['name'] or { json2.Any('') }
	score := res[0]['score'] or { json2.Any(0.0) }
	active := res[0]['active'] or { json2.Any(json2.null) }
	assert name == json2.Any('alice')
	assert score == json2.Any(95.5)
	// Verify boolean was retrieved
	assert active != json2.Any(json2.null)
}

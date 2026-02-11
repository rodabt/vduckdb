# vduckdb

A V wrapper for DuckDB - the fast SQL OLAP database engine.

## Quick Start

```v
import vduckdb

fn main() {
    mut vdb := vduckdb.DuckDB{}
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    _ := vdb.query("SELECT 1 as id, 'test' as name")!
    
    println(vdb.print_table())
}
```

## Core Types

| Type | Description |
|------|-------------|
| `DuckDB` | Main database instance |
| `State` | Query execution state (duckdbsuccess, duckdberror) |
| `OutputConfig` | Table formatting options |

## Main Functions

| Function | Description |
|----------|-------------|
| `open(filename: string)` | Open database (`:memory:` for in-memory) |
| `close()` | Close database connection |
| `query(sql: string)` | Execute SQL query |
| `dim() (int, int)` | Get result dimensions (rows, columns) |

## Data Retrieval

| Function | Description |
|----------|-------------|
| `get_array()` | Get results as `[]map[string]json2.Any` |
| `get_array_as_string()` | Get results as `[]map[string]string` |
| `get_first_row()` | Get first row as `map[string]string` |
| `get_data_as_table()` | Get results as HTML table |

## Display

| Function | Description |
|----------|-------------|
| `print_table(config: OutputConfig)` | Format results as table (modes: box, ascii, md, csv) |

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `num_rows` | `int` | Row count from last query |
| `num_columns` | `int` | Column count from last query |
| `columns` | `map[string]string` | Column names and types |
| `time_ms` | `string` | Last query execution time |
| `file` | `string` | Current database file path |

## Examples

### Load and Query Data

```v
mut vdb := vduckdb.DuckDB{}
_ := vdb.open(':memory:')!
defer { vdb.close() }

_ := vdb.query("CREATE TABLE users AS SELECT 1 as id, 'Alice' as name")!
_ := vdb.query("SELECT * FROM users")!

data := vdb.get_array_as_string()
for row in data {
    println('${row["name"]}: ${row["id"]}')
}
```

### Error Handling

```v
vdb.query("INVALID SQL") or {
    eprintln('Error: ${err.msg()}')
    return
}
```

### Multiple Output Formats

```v
_ := vdb.query("SELECT 1 as id, 'test' as name")!

println(vdb.print_table(mode: 'box'))   // Box format
println(vdb.print_table(mode: 'ascii')) // ASCII format
println(vdb.print_table(mode: 'md'))    // Markdown
println(vdb.print_table(mode: 'csv'))   // CSV
```

## See Also

- Main documentation: See root `README.md`
- Tests: See `queries_test.v` and `setup_test.v`

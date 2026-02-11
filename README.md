# vduckdb 0.7.0

[![CI](https://github.com/rodabt/vduckdb/workflows/Build%20and%20Test/badge.svg)](https://github.com/rodabt/vduckdb/actions)

A V wrapper for DuckDB - the fast SQL OLAP database engine. Write type-safe database queries in V with full access to DuckDB's powerful features.

**Status:** Production-ready (beta). Tested on Linux, Windows, and macOS with V 0.5.x+

## Why vduckdb?

- **Fast**: DuckDB is engineered for analytical queries on large datasets
- **Easy**: Simple V API with automatic library management
- **Flexible**: In-memory, file-based, or networked databases
- **Compatible**: Seamlessly load CSV, JSON, Parquet, Excel files
- **Extensible**: Access to DuckDB extensions and SQL functions

### Installation

- Download the latest DuckDB (`libduckdb*.zip`) for your OS from `https://github.com/duckdb/duckdb/releases`
- Extract the `.so` (Linux), `.dll` (Windows), or `.dylib` (macOS) file and rename it accordingly
- Copy it to your project root, a `thirdparty` subdirectory, or set the `LIBDUCKDB_DIR` environment variable

## vduckdb Installation

```bash
v install https://github.com/rodabt/vduckdb
```

## Quick Start

### Basic Example: Query a CSV File

```v
import vduckdb

fn main() {
    mut vdb := vduckdb.DuckDB{}
    
    // Open an in-memory database
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    // Query a remote CSV file
    url := 'https://example.com/data.csv'
    _ := vdb.query("SELECT * FROM '${url}' LIMIT 10")!
    
    // Display results
    println(vdb.print_table(max_rows: 10, mode: 'box'))
    println('Execution time: ${vdb.time_ms}')
}
```

### Working with Query Results

```v
import vduckdb

fn main() {
    mut vdb := vduckdb.DuckDB{}
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    // Execute query
    url := 'https://gist.githubusercontent.com/Sharanya1307/631c9f66e5709dbace46b5ed6672381e/raw/people-100.csv'
    _ := vdb.query("SELECT * FROM '${url}' LIMIT 5")!
    
    // Get results as array of string maps
    data := vdb.get_array_as_string()
    for row in data {
        println('Name: ${row["First Name"]}, Gender: ${row["Sex"]}')
    }
    
    // Get first row
    first := vdb.get_first_row()
    println('First row: ${first}')
    
    // Get result dimensions
    rows, cols := vdb.dim()
    println('Results: ${rows} rows × ${cols} columns')
}
```

### Data Format Control

```v
import vduckdb

fn main() {
    mut vdb := vduckdb.DuckDB{}
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    _ := vdb.query("SELECT 1 as id, 'Alice' as name UNION SELECT 2, 'Bob'")!
    
    // Box table format (default)
    println(vdb.print_table(mode: 'box', max_rows: -1))  // -1 shows all rows
    
    // ASCII table format
    println(vdb.print_table(mode: 'ascii'))
    
    // Markdown table format (for documentation)
    println(vdb.print_table(mode: 'md'))
    
    // CSV format
    println(vdb.print_table(mode: 'csv', delimiter: '|'))
}
```

### Working with Files

```v
import vduckdb
import os

fn main() {
    mut vdb := vduckdb.DuckDB{}
    
    // Open or create a persistent database file
    _ := vdb.open('my_data.duckdb')!
    defer { vdb.close() }
    
    // Create table from CSV (file must exist)
    if os.exists('users.csv') {
        _ := vdb.query("CREATE TABLE users AS SELECT * FROM 'users.csv'")!
    }
    
    // Create table from JSON
    if os.exists('logs.json') {
        _ := vdb.query("CREATE TABLE logs AS SELECT * FROM read_json_auto('logs.json')")!
    }
    
    // Create table from Parquet
    if os.exists('data.parquet') {
        _ := vdb.query("CREATE TABLE metrics AS SELECT * FROM 'data.parquet'")!
    }
    
    // Create table from Excel (requires EXCEL extension)
    if os.exists('sales.xlsx') {
        _ := vdb.query("INSTALL EXCEL; LOAD EXCEL")!
        _ := vdb.query("CREATE TABLE sales AS SELECT * FROM 'sales.xlsx'")!
    }
}
```

### Error Handling

```v
import vduckdb

fn main() {
    mut vdb := vduckdb.DuckDB{}
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    // Handle query errors gracefully
    vdb.query("INVALID SQL HERE") or {
        eprintln('Query failed: ${err.msg()}')
        return
    }
    
    // Safe column access with fallback
    first_row := vdb.get_first_row()
    value := first_row['column_name'] or { 'default_value' }
    println('Value: ${value}')
}
```

### Using DuckDB Extensions

```v
import vduckdb

fn main() {
    mut vdb := vduckdb.DuckDB{}
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    // Load JSON extension
    _ := vdb.query("INSTALL json; LOAD json")!
    _ := vdb.query("SELECT json_extract('[1, 2, 3]', '$[0]')")!
    
    // Load HTTP extension for web data
    _ := vdb.query("INSTALL httpfs; LOAD httpfs")!
    
    // Set memory limits and thread count
    _ := vdb.query("SET memory_limit = '4GB'")!
    _ := vdb.query("SET threads TO 8")!
}
```

## Complete Real-World Example

### Data Analytics Application

```v
import vduckdb

pub struct Report {
pub:
    name string
    total_rows int
    column_count int
    execution_time string
}

fn analyze_dataset(dataset_name string) !Report {
    mut vdb := vduckdb.DuckDB{}
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    // Create sample dataset
    _ := vdb.query("
        CREATE TABLE data AS 
        SELECT 
            'Product A' as product,
            100 as sales,
            CURRENT_DATE as date
        UNION ALL
        SELECT 'Product B', 250, CURRENT_DATE
        UNION ALL
        SELECT 'Product C', 150, CURRENT_DATE
    ")!
    
    // Get data overview
    _ := vdb.query("SELECT * FROM data")!
    
    rows, cols := vdb.dim()
    
    return Report{
        name: dataset_name
        total_rows: rows
        column_count: cols
        execution_time: vdb.time_ms
    }
}

fn main() {
    report := analyze_dataset('sales_data') or {
        eprintln('Analysis failed: ${err.msg()}')
        return
    }
    
    println('Report: ${report}')
}
```

## Common Patterns

### Aggregate and Summary Statistics

```v
import vduckdb

fn main() {
    mut vdb := vduckdb.DuckDB{}
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    _ := vdb.query("
        CREATE TABLE sales AS 
        SELECT 'Product A' as product, 100 as amount
        UNION ALL SELECT 'Product B', 250
        UNION ALL SELECT 'Product A', 150
    ")!
    
    _ := vdb.query("
        SELECT 
            product,
            COUNT(*) as count,
            SUM(amount) as total,
            AVG(amount) as average
        FROM sales
        GROUP BY product
        ORDER BY total DESC
    ")!
    
    println(vdb.print_table())
}
```

### Join Multiple Data Sources

```v
import vduckdb

fn main() {
    mut vdb := vduckdb.DuckDB{}
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    // Create sample data
    _ := vdb.query("
        CREATE TABLE customers AS 
        SELECT 1 as id, 'Alice' as name
        UNION ALL SELECT 2, 'Bob'
        UNION ALL SELECT 3, 'Charlie'
    ")!
    
    _ := vdb.query("
        CREATE TABLE orders AS 
        SELECT 1 as id, 1 as customer_id, 100.0 as total
        UNION ALL SELECT 2, 1, 150.0
        UNION ALL SELECT 3, 2, 200.0
        UNION ALL SELECT 4, 1, 75.0
    ")!
    
    // Join and aggregate
    _ := vdb.query("
        SELECT 
            c.name,
            COUNT(o.id) as order_count,
            SUM(o.total) as total_spent
        FROM customers c
        LEFT JOIN orders o ON c.id = o.customer_id
        GROUP BY c.id, c.name
        ORDER BY total_spent DESC
    ")!
    
    data := vdb.get_array_as_string()
    for row in data {
        if row["order_count"] != '0' {
            println('${row["name"]}: ${row["order_count"]} orders, \$${row["total_spent"]}')
        }
    }
}
```

### Transform and Export

```v
import vduckdb

fn main() {
    mut vdb := vduckdb.DuckDB{}
    _ := vdb.open(':memory:')!
    defer { vdb.close() }
    
    // Create sample data
    _ := vdb.query("
        CREATE TABLE raw_data AS
        SELECT 'alice' as name, 25 as age
        UNION ALL SELECT 'bob', 17
        UNION ALL SELECT 'charlie', 30
    ")!
    
    // Transform and create processed table
    _ := vdb.query("
        CREATE TABLE processed AS
        SELECT 
            UPPER(name) as name,
            CAST(age as INTEGER) as age,
            CURRENT_DATE as processed_date
        FROM raw_data
        WHERE age > 18
    ")!
    
    // Display results
    _ := vdb.query("SELECT * FROM processed")!
    println(vdb.print_table())
}
```

## API Reference

### Core Methods

| Method                   | Description                                                |
| ------------------------ | ---------------------------------------------------------- |
| `open(filename: string)` | Open database connection (use `:memory:` for in-memory DB) |
| `close()`                | Close database connection                                  |
| `query(sql: string)`     | Execute SQL query                                          |
| `dim() (int, int)`       | Get result dimensions (rows, columns)                      |

### Data Access

| Method                                              | Description                   |
| --------------------------------------------------- | ----------------------------- |
| `get_array() []map[string]json2.Any`               | Get results with native types |
| `get_array_as_string() []map[string]string`        | Get results as strings        |
| `get_array_as_string_with_limit(lo: LimitOptions)` | Get results with row limit    |
| `get_first_row() map[string]string`                | Get first row as string map   |
| `get_data_as_table() string`                       | Get results as HTML table     |

### Display

| Method                                     | Description             |
| ------------------------------------------ | ----------------------- |
| `print_table(config: OutputConfig) string` | Format results as table |

### Properties

| Property      | Type              | Description                      |
| ------------- | ----------------- | -------------------------------- |
| `num_rows`    | int               | Number of rows in last result    |
| `num_columns` | int               | Number of columns in last result |
| `columns`     | map[string]string | Column names and types           |
| `time_ms`     | string            | Last query execution time        |
| `file`        | string            | Current database file path       |

## Real-World Usage in Production

vduckdb is used in several production applications:

- **vframes**: DataFrame operations with SQL queries
- **cuiqviz**: Data visualization with multi-format support (CSV, JSON, Parquet, Excel)
- **cuiqData**: ETL pipeline execution with complex transformations
- **cuiqMetrics**: Real-time metrics collection and analysis

See `/home/rabt/devel/vframes`, `/home/rabt/devel/cuiqviz`, and `/home/rabt/devel/cuiqData` for complete examples.

## Development

```bash
# Run tests
make test

# Format code
make fmt

# Generate HTML documentation
make docs

# View documentation
v doc vduckdb
```

## Roadmap

- [x] Define as module
- [x] Added tests
- [x] Write base documentation
- [x] Download and install required dependencies
- [x] Map all relevant definitions from `duckvdb.h` header file to their V counterparts
- [x] Create convenience functions and data wrappers
- [ ] Add website and tutorials
- [ ] Build integration with V ORM

## Troubleshooting

### Library not found error

Set the `LIBDUCKDB_DIR` environment variable:

```bash
LIBDUCKDB_DIR=/path/to/lib v run example.v
```

### Memory issues with large datasets

Use DuckDB's memory settings:

```v
_ := vdb.query("SET memory_limit = '8GB'")!
```

### Performance optimization

For analytical queries on large data:

```v
_ := vdb.query("SET threads TO 16")!  // Use more threads
_ := vdb.query("PRAGMA memory_limit='16GB'")!  // Increase memory
```

## Contributing

Pull requests are welcome. Please ensure tests pass before submitting.

## License

See LICENSE file for details.

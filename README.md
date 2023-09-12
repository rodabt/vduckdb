# vduckdb 0.5.0

A V wrapper for duckdb. This library is now in beta and should be safe to use in most scenarios. Should work on Linux, Windows and MacOS

## Requirements

A working V version (0.4.x or higher)

## Installation

```bash
v install vduckdb
```

## Main usage

```v
import vduckdb

fn main() {
  
  mut db := vduckdb.DuckDB{}
  println('duckdb version: ${vduckdb.version()}\n')
  file := ':memory:'
  mut result_state := db.open(file)

  if result_state == vduckdb.State.duckdberror {
    println('Error opening DB ${file}')
  }

  result_state = db.connect()

  if result_state == vduckdb.State.duckdberror {
    println('Error connecting to DB')
  }

  sql := "select * from 'people-100.csv'"
  println('Query:\n${sql}\n')

  result_state = db.query(sql)

  if result_state == vduckdb.State.duckdberror {
    println('Error executing query: ${sql}')
  }

  println('Columns ${db.columns}')
  println(db.data(max_rows: -1, mode: 'box'))

  defer {
    db.close()
  }
}
```

## Documentation

Run `v doc vduckdb` or `make docs` to generate static HTML documentation in `docs` folder

## Roadmap

- [x] Define as module
- [x] Added tests
- [x] Write base documentation
- [x] Download and install required dependencies
- [x] Map all relevant definitions from `duckdb.h` header file to their V counterparts
- [x] Create convenience functions and data wrappers
- [ ] Add website and tutorials
- [ ] Build integration with V ORM

## Contributing

Pull requests are welcome

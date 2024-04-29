# vduckdb 0.6.2

A V wrapper for duckdb. This library is now in beta and should be safe to use in most scenarios. Should work on Linux, Windows and MacOS.

## Requirements

A working V version (0.4.x or higher)

## Installation

```bash
v install rodabt.vduckdb
```

## Main usage

```v
import rodabt.vduckdb

fn main() {
  
  mut db := vduckdb.DuckDB{}
  println('vduckdb version: ${vduckdb.version()}\n')
  println('duckdb version: ${vduckdb.duckdb_library_version()}\n')
  file := ':memory:'
  mut result_state := db.open(file)!

  if result_state == vduckdb.State.duckdberror {
    println('Error opening DB ${file}')
  }

  q := "select * from 'people-100.csv'"
  println('Query:\n${q}\n')

  result_state = db.query(q)!

  if result_state == vduckdb.State.duckdberror {
    println('Error executing query: ${q}')
  }

  println('Columns ${db.columns}')
  println(db.print_table(max_rows: 10, mode: 'box'))

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

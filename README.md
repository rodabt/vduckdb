# vduckdb 0.5.0

A V wrapper for duckdb. This library is now in beta and should be safe to use in most scenarios.

_WARNING: At the moment it's working only for Linux_.  

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
  mut res := db.open(file)

  if res == vduckdb.State.duckdberror {
    println('Error opening DB ${file}: ${res}')
  }

  res = db.connect()

  if res == vduckdb.State.duckdberror {
    println('Error connecting to DB: ${res}')
  }

  sql := "select * from 'people-100.csv'"
  println('Query:\n${sql}\n')

  res = db.query(sql)

  if res == vduckdb.State.duckdberror {
    println('Error executing query: ${res}')
  }

  println('Columns ${v.columns}')
  println(db.data(max_rows: -1, mode: 'box'))

  defer {
    db.close()
  }
}
```

## Documentation

`make docs` will generate HTML documentation in a new `docs` folder

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

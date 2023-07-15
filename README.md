# vduckdb 0.4.0

A V wrapper for duckdb, using the C/C++ libraries provided by DuckDB.

This library is now in beta and should be safe to use in most scenarios.

## Requirements

- A working V version 0.3.x or higher

## Installation

```bash
v install vduckdb
```

## Main usage

```v
import vduckdb

fn main() {
  db := &vduckdb.Database{}
  if duckdb.open(c'file.db', db) == vduckdb.State.duckdbsuccess {
    println("Success")
  } else {
    println("Could not open database")
  }
  // ...
}
```

Check [examples/simple_example.v](examples/simple_example.v) for a more detailed example

## Documentation

`make docs` will generate HTML documentation in a new `docs` folder

## Roadmap

- [x] Define as module
- [x] Added tests
- [x] Write base documentation
- [x] Download and install required dependencies
- [x] Map all relevant definitions from `duckdb.h` header file to their V counterparts
- [ ] Add website and tutorials
- [ ] Build integration with V ORM

## Contributing

Pull requests are welcome

## Changelog

- 067/15/2023 - Huge refactoring
  - No more libduckdb previous installation. Shared library is shipped and loaded dynamically with the module
  - A more simplified wrapper using const functions
- 06/20/2023 - Renamed module to vduckdb
- 06/19/2023:
  - Added column type identification. Breaking change: dropped `print_table` (use termtable if you need to print to stdout)
  - Added specific returning types for most common V types, except dates
  - Changed to a better data example (from [https://www.datablist.com/learn/csv/download-sample-csv-files])
  - Added more tests
- 06/09/2023 - Fixed installation process and import reference. Bump to version 0.1.0
- 06/07/2023 - Added docs generator
- 05/28/2023 - Added instructions for libduckdb on Linux
- 05/27/2023 - Added print_table utility
- 05/21/2023 - Added simple data output with value_varchar
- 05/20/2023 - Refactored as V Module
- 05/17/2023 - Completed a simple query cycle
- 05/16/2023 - Added connection and query functions, and a simple Makefile
- 05/12/2023 - First commit to test library integration with working code

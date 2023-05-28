# vduck

A V wrapper for duckdb, using the C/C++ libraries provided by DuckDB.

ATTENTION: this version is in very alpha stage, use at your own risk...

## Requirements

- A working V version 0.3.x or higher
- `libduckdb` in your Lib path

### Installing `libduckdb.so` in Linux

- Download the C/C++ zipfile from [https://duckdb.org/docs/installation/](https://duckdb.org/docs/installation/)
- Copy library to an accesible lib directory, i.e. : `sudo cp libduckdb.so /usr/lib/local`
- Rebuild cache: `sudo ldconfig`

## Main usage

```v
import duckdb

fn main() {
  db := &duckdb.Database{}
  if duckdb.open(c'file.db', db) == duckdb.State.duckdbsuccess {
    println("Success")
  } else {
    println("Could not open database")
  }
  // ...
}
```

Check [example.v](example.v) for a more detailed example

## Roadmap

- [x] Define as module
- [x] Added tests
- [ ] Map all definitions from `duckdb.h` header file to their V counterparts
- [ ] Add website
- [ ] Write documentation, and tutorials
- [ ] Build integration with V ORM

## Changelog

- 05/28/2023: Added instructions for libduckdb on Linux
- 05/27/2023: Added print_table utility
- 05/21/2023: Added simple data output with value_varchar
- 05/20/2023: Refactored as V Module
- 05/17/2023: Completed a simple query cycle
- 05/16/2023: Added connection and query functions, and a simple Makefile
- 05/12/2023: First commit to test library integration with working code

# vduck

A V wrapper for duckdb, using the C/C++ libraries provided by DuckDB.

ATTENTION: this version is in very alpha stage, use at your own risk...

## Requirements

- A working V version 0.3.x or higher
- `libduckdb` in your path. Check DuckDB documentation

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

Check [example.v](example.v) for a reference

## Roadmap

- [x] Define as module
- [ ] Map all definitions from `duckdb.h` header file to their V counterparts
- [ ] Write documentation, tutorials and tests
- [ ] Build integration with V ORM

## Changelog

- 05/21/2023: Added simple data output with value_varchar
- 05/20/2023: Refactored as V Module
- 05/17/2023: Completed a simple query cycle
- 05/16/2023: Added connection and query functions, and a simple Makefile
- 05/12/2023: First commit to test library integration with working code

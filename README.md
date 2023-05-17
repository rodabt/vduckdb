# vduck

A V wrapper for duckdb, using the C/C++ libraries provided by DuckDB

## Requirements

- A working V version 0.3.x or higher
- `duckdb.h` and `libduckdb.so` downloaded from DuckDB site

## Roadmap

- [ ] Map all definitions from `duckdb.h` header file to their V counterparts
- [ ] Define module structure
- [ ] Write documentation, tutorials and tests
- [ ] Build integration with V ORM

## Changelog

- 05/12/2023: First commit to test library integration with working code
- 05/16/2023: Added connection and query functions, and a simple Makefile

# vduckdb 0.6.3

A V wrapper for duckdb. This library is now in beta and should be safe to use in most scenarios. Should work on Linux, Windows and MacOS.

**Important upcoming API change for next version 0.6.4**:

Functions such as `open`, `connect`, and `query` functions will no longer return a `State` because they already return `Result` which renders a `State` value useless

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
    println('vduckdb version: ${vduckdb.version()}')
    println('duckdb version: ${vduckdb.duckdb_library_version()}')

    file := ':memory:'
    _ := db.open(file)!  // Note: output will change on next version

    mut q := 'select "Index", "First Name", "Last Name", "Email", "Date of birth" from \'people-100.csv\' limit 10'
    println('\nQuery: ${q}')

    _ = db.query(q)!    // Note: ouput will change on next version

    println('\nColumns and types: ${db.columns}')
    
    println('\n Results as table to terminal:')
    println(db.print_table(max_rows: 10, mode: 'box'))

    q = 'select "First Name", "Sex" from \'people-100.csv\' limit 5'
    println('\nData from \'${q}\' as []map[string]string:')
    _ = db.query(q)!
    out := db.get_array_as_string()
    println(out)

    println('\nManaging errors...')
    q = "select sdkf fff f"
    db.query(q) or {
      eprintln(err.msg())
    }

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

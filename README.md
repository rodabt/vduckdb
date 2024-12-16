# vduckdb 0.6.5

A V wrapper for duckdb. This library is now in beta and should be safe to use in most scenarios. Should work on Linux, Windows and MacOS with V version 0.4.x 

## DuckDB Libraries installation

- Download latest DuckDB libraries (`libduckdb*.zip`) for your OS from `https://github.com/duckdb/duckdb/releases` to `./thirdparty` in your current directory, or to a directory of your choice if you will use `LIBDUCKDB_DIR` env variable (see Usage)
- Make sure libraries are named `libduck*` (i.e. `libduckdb.so, libduckdb.dll, libduckdb.dylib`). Check the `update-libs.sh` script as a guideline.

## vduckdb installation

```bash
v install https://github.com/rodabt/vduckdb
```

## Main usage

```v
// file.v
import vduckdb

fn main() {
    
    mut db := vduckdb.DuckDB{}
    println('vduckdb version: ${vduckdb.version()}')
    println('duckdb version: ${vduckdb.duckdb_library_version()}')

    _ := db.open(':memory:')!

    mut q := 'select "Index", "First Name", "Last Name", "Email", "Date of birth" from \'people-100.csv\' limit 10'
    println('\nQuery: ${q}')

    _ := db.query(q)!

    println('\nColumns and types: ${db.columns}')
    
    println('\n Results as table to terminal:')
    println(db.print_table(max_rows: 10, mode: 'box'))

    q = 'select "First Name", "Sex" from \'people-100.csv\' limit 5'
    println('\nData from \'${q}\' as []map[string]string:')
    _ := db.query(q)!
    out := db.get_array_as_string()
    println(out)

    first_row := db.get_first_row()
    println(first_row)

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

```bash
# If you have `thirdparty` directory and its contents in the same directory as `file.v`
v run file.v

# Otherwise
LIBDUCKDB_DIR=/my/custom/libduckdb/directory v run file.v
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

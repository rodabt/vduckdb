# vduckdb 0.6.6

A V wrapper for duckvdb. This library is now in beta and should be safe to use in most scenarios. Should work on Linux, Windows and MacOS with V version 0.4.x. It requires the library version (`libduckdb*`) of DuckDB (see `https://github.com/duckdb/duckdb/releases`)

## DuckDB library installation

- Download the latest DuckDB (`libduckdb*.zip`) for your OS from `https://github.com/duckdb/duckdb/releases` and unzip the archive
- Pick the `.so` (Linux), `.dll` (Windows), or `.dylib` (OS X) file and rename it to `libduckvdb.so`, `libduckvdb.dll`, or `libduckvdb.dylib` accordingly
- Copy or move the file to the root directory where your V code is, or to a subdirectory called `thirdparty` or set a global variable called `LIBDUDCKDB_DIR`

## vduckdb installation

```bash
v install https://github.com/rodabt/vduckdb
```

## Main usage

```v
// example.v
import vduckdb

fn main() {

    mut vdb := vduckdb.DuckDB{}
    println('vduckdb version: ${vduckdb.version()}')
    println('duckdb version: ${vduckdb.duckdb_library_version()}')

    _ := vdb.open(':memory:')!

        db_file := 'https://gist.githubusercontent.com/Sharanya1307/631c9f66e5709dbace46b5ed6672381e/raw/4329c1980eac3a71b881b18757a5bfabd2a95a1e/people-100.csv'

    mut q := "select * from '${db_file}' limit 10"
    println('\nQuery: ${q}')

    _ := vdb.query(q)!

    println('\nColumns and types: ${vdb.columns}')

    println('\n Results as table to terminal:')
    println(vdb.print_table(max_rows: 10, mode: 'box'))

    q = "select \"First Name\", \"Sex\" from '${db_file}' limit 5"
    println('\nData from \'${q}\' as []map[string]string:')
    _ := vdb.query(q)!
    out := vdb.get_array_as_string()
    println(out)

    first_row := vdb.get_first_row()
    println(first_row)

    println('\nManaging errors...')
    q = "invalid query..."
    vdb.query(q) or {
      eprintln(err.msg())
    }
    vdb.close()
}
```

```bash
$ v run example.v
```

## Documentation

Run `v doc vduckdb` or `make docs` to generate static HTML documentation in `docs` folder

## Roadmap

- [x] Define as module
- [x] Added tests
- [x] Write base documentation
- [x] Download and install required dependencies
- [x] Map all relevant definitions from `duckvdb.h` header file to their V counterparts
- [x] Create convenience functions and data wrappers
- [ ] Add website and tutorials
- [ ] Build integration with V ORM

## Contributing

Pull requests are welcome

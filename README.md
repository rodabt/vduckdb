# vduckdb 0.6.9-b

[![CI](https://github.com/rodabt/vduckdb/workflows/Build%20and%20Test/badge.svg)](https://github.com/rodabt/vduckdb/actions)

A V wrapper for duckvdb. This library is now in beta and should be safe to use in most scenarios. Should work on Linux, Windows and MacOS with V version 0.4.x. It requires the library version (`libduckdb*`) of DuckDB (see `https://github.com/duckdb/duckdb/releases`)

## DuckDB library installation

The DuckDB library is automatically downloaded and managed for you! The project includes a V-native installer that:

- **Cross-platform**: Works on Linux, macOS, and Windows
- **Automatically detects** your operating system and architecture
- **Downloads the latest** compatible DuckDB library
- **Installs it correctly** for your platform
- **Keeps it updated** when new versions are available

### Quick Setup

```bash
# Install/update the DuckDB library for your platform
make install-libs

# Or run the full setup (install libs + run tests)
make setup
```

### Manual Installation (if needed)

If you prefer manual installation:

- Download the latest DuckDB (`libduckdb*.zip`) for your OS from `https://github.com/duckdb/duckdb/releases`
- Pick the `.so` (Linux), `.dll` (Windows), or `.dylib` (OS X) file and rename it to `libduckdb.so`, `libduckdb.dll`, or `libduckdb.dylib` accordingly
- Copy or move the file to the root directory where your V code is, or to a subdirectory called `thirdparty` or set a global variable called `LIBDUCKDB_DIR`

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
    println('\nExecution time: ${vdb.time_ms}')

    println('\n Results as table to terminal:')
    println(vdb.print_table(max_rows: 10, mode: 'box'))  // other options are: ascii and md

    q = 'select "First Name", "Sex" from \'${db_file}\' limit 5'
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

For example in Linux if `libduckdb.so` is in the same directory of your code or is in the `thirdparty` sub directory, then you can run:

```bash
$ v run example.v
```

Otherwise you have to specify the directory with the `LIBDUCKDB_DIR` enviromental variable like this:

```bash
LIBDUCKDB_DIR=/home/user/libdir v run .
```

## Documentation

Run `v doc vduckdb` or `make docs` to generate static HTML documentation in `docs` folder

## Development Commands

```bash
# Install/update DuckDB library for current platform
make install-libs

# Clean downloaded libraries
make clean-libs

# Run tests
make test

# Full project setup (install libs + run tests)
make setup

# Format code
make fmt

# Generate documentation
make docs
```

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

### Development Setup

The project includes a V-native installer that works on all platforms:

- `src/install_duckdb.v` - Cross-platform DuckDB library installer written in V
- No external dependencies - everything runs natively in V

### Library Management

The DuckDB library is automatically managed and should not be committed to the repository. The `.gitignore` file ensures that:

- `thirdparty/` directory is excluded
- Library files (`.dylib`, `.so`, `.dll`) are excluded
- Build artifacts are excluded

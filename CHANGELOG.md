# Changelog

## version 0.6.9-b

- Added execution time variable db.time_ms (string)
- Breaking changes: 
    - Added function get_data_as_table() that replaces gen_html() that now is marked as deprecated
    - gen_table() no longer generates html either

## version 0.6.9

- Added `mode: html` option to output of `print_table`
- Added new function `get_array_as_string_with_limit(n: int value)`. Default is 100.
- Added explicit `NULL` literal string to NULL outputs when using `get_array_as_string` or `get_array_as_string_with_limit`  

## version 0.6.8

- Added markdown output for print_table

## version 0.6.7

- Fixed strange rare error when using print_table, and a type on README

## version 0.6.6

- Eliminated fatal error compilation when libduckdb library is not present 

## version 0.6.5

- Fixed HugeInt

## version 0.6.4

- Minor code refactoring

## version 0.6.3-pre4: 2024-07-12

- Preparing changes for 0.6.4

## version 0.6.3: 2024-07-11

- More tests
- Changed panics to error for better control
- Changed example

## version 0.6.2: 2024-05-23

- Updated shell updating scripts

## version 0.6.1: 2024-04-29

- Added function to gey duckdb library version
- Padded table output according to data type

## version 0.6.0: 2024-01-19

- Fixed memory issues
- Added date and smallint formats

## 2023-08-31

- Simplified api
- Tested on Linux, Mac, and Windows

## 2023-08-27

- No more termtable dependences

## 20230-07-15

- Huge refactoring
- No need to install libduckdb as a requirement. Shared library is shipped and loaded dynamically with the module
- Simplified wrapper using const functions

## 2023-06-20

- Module renamed to vduckdb

## 2023-06-19

- Added column type identification. Breaking change: dropped `print_table`
- Added specific returning types for most common V types, except dates
- Better data example (from [https://www.datablist.com/learn/csv/download-sample-csv-files])
- Added more tests

## 2023-05-12

- First commit to test library integration with working code

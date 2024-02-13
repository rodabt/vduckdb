# Changelog

## version 0.6.1: 2024-01-23

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

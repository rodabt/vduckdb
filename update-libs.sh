#!/bin/bash

LATEST_TAG=$(curl -s https://api.github.com/repos/duckdb/duckdb/releases/latest | jq -r '.tag_name')
LIB_LINUX="https://github.com/duckdb/duckdb/releases/download/${LATEST_TAG}/libduckdb-linux-amd64.zip"
LIB_MAC="https://github.com/duckdb/duckdb/releases/download/${LATEST_TAG}/libduckdb-osx-universal.zip"
LIB_WINDOWS="https://github.com/duckdb/duckdb/releases/download/${LATEST_TAG}/libduckdb-windows-amd64.zip"

echo "Updating..."
mkdir -p ./src/thirdparty
rm ./src/thirdparty/*
wget $LIB_LINUX -P ./src/thirdparty/
wget $LIB_MAC -P ./src/thirdparty/
wget $LIB_WINDOWS -P ./src/thirdparty/

echo "Uncompressing..."
unzip -j -o ./src/thirdparty/libduckdb-linux-amd64.zip -d "./src/thirdparty/" libduckdb.so duckdb.h
unzip -j -o ./src/thirdparty/libduckdb-osx-universal.zip -d "./src/thirdparty/" libduckdb.dylib
unzip -j -o ./src/thirdparty/libduckdb-windows-amd64.zip -d "./src/thirdparty/" duckdb.dll 
mv ./src/thirdparty/duckdb.dll ./src/thirdparty/libduckdb.dll
rm ./src/thirdparty/*.zip


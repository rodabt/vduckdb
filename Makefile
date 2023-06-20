.PHONY: run docs fmt test

run:
	v run example.v

docs:
	VDOC_SORT=false v doc -no-timestamp -readme -f html duckdb/ -o doc	

fmt: 
	v fmt -w vduckdb

test:
	v -stats test tests/
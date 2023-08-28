.PHONY: docs fmt test

docs:
	VDOC_SORT=false v doc -no-timestamp -readme -f html ./vduckdb -o docs

fmt:
	v fmt -w vduckdb/.

test:
	v -stats test vduckdb/*_test.v

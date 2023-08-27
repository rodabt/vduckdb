.PHONY: docs fmt test

docs:
	VDOC_SORT=false v doc -all -no-timestamp -readme -f html ../vduck -o docs

fmt:
	v fmt -w vduckdb/.

test:
	v -stats test vduckdb/*_test.v

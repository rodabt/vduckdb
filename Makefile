.PHONY: docs fmt test

docs:
	VDOC_SORT=false v doc -no-timestamp -readme -f html ./vduckdb -o docs

fmt:
	v fmt -w src/

test:
	cd src && v -stats test . && cd ..


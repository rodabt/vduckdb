.PHONY: docs fmt test local

local:
	ln -s ~/devel/vduckdb ~/.vmodules/vduckdb

docs:
	VDOC_SORT=false v doc -no-timestamp -readme -f html ./vduckdb -o docs

fmt:
	v fmt -w src/

test:
	v -stats test src/*_test.v

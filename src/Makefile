.PHONY: docs fmt test

docs:
	VDOC_SORT=false v doc -color -no-timestamp -readme -f html . -o ../docs

fmt:
	v fmt -w src/

test:
	v -stats test .


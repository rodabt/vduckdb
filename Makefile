.PHONY: docs fmt test

docs:
	VDOC_SORT=false v doc -no-timestamp -readme -f html ../vduck -o docs

fmt:
	v fmt -w wrapper.v

test:
	v -stats test *_test.v

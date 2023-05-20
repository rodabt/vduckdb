run:
	LD_LIBRARY_PATH=. v run example.v && rm here.db*

fmt: 
	v fmt -w main.v
.PHONY: local docs fmt test install-libs clean-libs

local:
	ln -s ~/devel/vduckdb ~/.vmodules/vduckdb

docs:
	VDOC_SORT=false v doc -no-timestamp -readme -f html ./vduckdb -o docs

fmt:
	v fmt -w src/

test:
	cd src && v -stats test . && cd ..

# Install/update DuckDB library for current platform
install-libs:
	@echo "Installing DuckDB library for current platform..."
	@v run src/install_duckdb.v

# Clean downloaded libraries (keeps symlinks)
clean-libs:
	@echo "Cleaning downloaded libraries..."
	@rm -f ./thirdparty/libduckdb.*
	@rm -f ./src/thirdparty/libduckdb.*
	@rm -f ./thirdparty/duckdb.h
	@rm -f ./src/thirdparty/duckdb.h
	@echo "Libraries cleaned. Run 'make install-libs' to reinstall."

# Setup project (install dependencies and run tests)
setup: install-libs test
	@echo "Project setup complete!" 
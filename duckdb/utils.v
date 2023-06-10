module duckdb

import v.vmod

fn print_row(elems []string, widths []int, top bool) {
	if top {
		print('+')
		for index, _ in elems {
			mut x := '-'.repeat(widths[index] + 2)
			print(x)
			print('+')
		}
		println('')
	}
	print('|')
	for index, elem in elems {
		mut s := ' '.repeat(widths[index] - elem.len + 2)
		mut x := '${elem}${s}'.limit(30)
		print(x)
		print('|')
	}
	println('')
	print('+')
	for index, _ in elems {
		mut x := '-'.repeat(widths[index] + 2)
		print(x)
		print('+')
	}
	println('')
}

pub fn print_table(array [][]string, header []string) {
	mut column_widths := []int{len: header.len, init: 0}
	for row in array {
		for index, element in row {
			if element.len > column_widths[index] {
				column_widths[index] = element.len
			}
		}
	}
	print_row(header, column_widths, true)
	for row in array {
		print_row(row, column_widths, false)
	}
}

pub fn vduck_version() string {
	vm := vmod.decode(@VMOD_FILE) or { panic(err) }
	return vm.version
}

module vduckdb

import x.json2

const table_type = {
	'ascii': {
		// Top chars
		'tl':   '+'
		'line': '-'
		'ts':   '+'
		'tr':   '|'
		// Middle chars
		'ms':   '+'
		'mls':  '+'
		'mrs':  '+'
		'sep':  '|'
		// Bottom chars
		'bl':   '+'
		'br':   '|'
		'bs':   '+'
	}
	'box':   {
		// Top chars
		'tl':   '┌'
		'line': '─'
		'ts':   '┬'
		'tr':   '┐'
		// Middle chars
		'ms':   '┼'
		'mls':  '├'
		'mrs':  '┤'
		'sep':  '│'
		// Bottom chars
		'bl':   '└'
		'br':   '┘'
		'bs':   '┴'
	}
}

// TODO: Print in streaming fashion....
fn gen_table(o OutputConfig, data []map[string]json2.Any, limit int) string {
	chars := vduckdb.table_type[o.mode].clone()

	mut table := []string{}
	// Get the keys from the first map to use as table headers
	keys := data[0].keys()
	mut col_widths := []int{}

	// Calculate the maximum width for each column
	for key in keys {
		mut max_width := key.len
		for row in data {
			value := row[key] or { json2.Any('') }
			if value.str().len > max_width {
				max_width = value.str().len
			}
		}
		col_widths << max_width
	}

	// Top header line
	mut top := chars['tl']
	for col_width in col_widths {
		top += chars['line'].repeat(col_width + 2) + chars['ts']
	}
	top = top.all_before_last(chars['ts']) + chars['tr']

	// Middle header line
	mut middle := chars['mls']
	for col_width in col_widths {
		middle += chars['line'].repeat(col_width + 2) + chars['ms']
	}
	middle = middle.all_before_last(chars['ms']) + chars['mrs']

	// Bottom line
	mut bottom := chars['bl']
	for col_width in col_widths {
		bottom += chars['line'].repeat(col_width + 2) + chars['bs']
	}
	bottom = bottom.all_before_last(chars['bs']) + chars['br']

	mut headers := ''

	table << top
	for i, key in keys {
		headers += chars['sep'] + ' ' + key + ' '.repeat(col_widths[i] - key.len) + ' '
	}
	headers += chars['sep']
	table << headers
	table << middle

	// Print the table rows
	for row in data[0..limit] {
		mut line := ''
		for i, key in keys {
			value := row[key] or { json2.Any('') }
			line += chars['sep'] + ' ' + value.str() + ' '.repeat(col_widths[i] - value.str().len) +
				' '
		}
		line += chars['sep']
		table << line
	}
	table << bottom
	table << 'Total rows: ${limit}'
	return table.join('\n')
}

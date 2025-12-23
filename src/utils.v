module vduckdb

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
	'md':    {
		// Top chars
		'tl':   '|'
		'line': '-'
		'ts':   '|'
		'tr':   '|'
		// Middle chars
		'ms':   '|'
		'mls':  '|'
		'mrs':  '|'
		'sep':  '|'
		// Bottom chars
		'bl':   '|'
		'br':   '|'
		'bs':   ' '
	}
	'html':  {}
}

// TODO: Print in streaming fashion....
fn gen_table(o OutputConfig, data []map[string]string, limit int) string {
	/* if o.mode == 'html' {
		return gen_html(data, limit)
	} */
	chars := table_type[o.mode].clone()

	mut table := []string{}
	// Get the keys from the first map to use as table headers
	keys := data[0].keys()
	mut col_widths := []int{}

	// Calculate the maximum width for each column
	for key in keys {
		mut max_width := key.runes().len
		for row in data {
			value := row[key]
			if value.runes().len > max_width {
				max_width = value.runes().len
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

	if o.mode in ['box', 'ascii'] {
		table << top
	}
	for i, key in keys {
		headers += chars['sep'] + ' ' + key + ' '.repeat(col_widths[i] - key.runes().len) + ' '
	}
	headers += chars['sep']
	table << headers
	table << middle

	// Print the table rows
	for row in data[0..limit] {
		mut line := ''
		for i, key in keys {
			value := row[key]
			line += chars['sep'] + ' ' + value + ' '.repeat(col_widths[i] - value.runes().len) + ' '
		}
		line += chars['sep']
		table << line
	}
	if o.mode in ['box', 'ascii'] {
		table << bottom
	}
	table << '\nTotal rows: ${limit}'
	return table.join('\n')
}

@[deprecated: 'use get_data_as_table()']
fn gen_html(data []map[string]string, limit int) string {
	header := if data.len > 0 {
		'<tr>' + data[0].keys().map('<th>' + it + '</th>').join_lines() + '</tr>'
	} else {
		''
	}
	mut rows := []string{}
	if data.len > 0 {
		for row in data[0..limit] {
			rows << '<tr>' + row.values().map('<td>' + it + '</td>').join_lines() + '</tr>'
		}
	}
	table := if data.len > 0 {
		'
	<table>
		<thead>
		${header}
		</thead>
		<tbody>
		${rows.join_lines()}
		</tbody>
	</table>
	'
	} else {
		''
	}
	return table
}

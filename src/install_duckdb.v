module main

import os
import net.http
import json

struct DuckDBRelease {
	tag_name string
}

struct DuckDBAsset {
	name                 string
	browser_download_url string
}

struct DuckDBReleaseResponse {
	tag_name string
	assets   []DuckDBAsset
}

fn main() {
	println('🦆 DuckDB Library Installer for vduckdb')
	println('========================================')

	// Detect platform
	platform := detect_platform()
	println('📱 Detected platform: ${platform}')

	// Get latest version
	version := get_latest_version() or {
		println('❌ Failed to get latest version: ${err}')
		return
	}
	println('📦 Latest DuckDB version: ${version}')

	// Install library
	install_library(platform, version) or {
		println('❌ Failed to install library: ${err}')
		return
	}

	println('✅ DuckDB library installation completed successfully!')
	println('🧪 You can now run: make test')
}

fn detect_platform() string {
	os_name := os.user_os()

	match os_name {
		'linux' {
			// Try to detect architecture
			arch_cmd := 'uname -m'
			result := os.execute(arch_cmd)
			if result.exit_code == 0 {
				arch := result.output.trim_space()
				if arch == 'aarch64' || arch == 'arm64' {
					return 'linux-arm64'
				} else if arch == 'x86_64' || arch == 'amd64' {
					return 'linux-amd64'
				}
			}
			// Fallback to amd64
			return 'linux-amd64'
		}
		'macos' {
			return 'osx-universal'
		}
		'windows' {
			return 'windows-amd64'
		}
		else {
			return 'linux-amd64' // fallback
		}
	}
}

fn get_latest_version() !string {
	println('🔍 Fetching latest DuckDB version...')

	// Try DuckDB's latest version endpoint first
	response := http.get('https://duckdb.org/data/latest_stable_version.txt') or {
		println('⚠️  Could not fetch from DuckDB endpoint, trying GitHub API...')
		return get_latest_version_from_github()
	}

	if response.status_code == 200 {
		version := response.body.trim_space()
		if version.len > 0 {
			// Add 'v' prefix if missing
			if !version.starts_with('v') {
				return 'v${version}'
			}
			return version
		}
	}

	return get_latest_version_from_github()
}

fn get_latest_version_from_github() !string {
	response := http.get('https://api.github.com/repos/duckdb/duckdb/releases/latest') or {
		return error('Failed to fetch from GitHub API: ${err}')
	}

	if response.status_code != 200 {
		return error('GitHub API returned status ${response.status_code}')
	}

	release := json.decode(DuckDBReleaseResponse, response.body) or {
		return error('Failed to parse GitHub API response: ${err}')
	}

	return release.tag_name
}

fn install_library(platform string, version string) ! {
	println('📥 Installing DuckDB library for ${platform}...')

	// Create directories
	os.mkdir_all('thirdparty') or { return error('Failed to create thirdparty directory: ${err}') }
	os.mkdir_all('src/thirdparty') or {
		return error('Failed to create src/thirdparty directory: ${err}')
	}

	// Determine library filename and extension
	lib_ext := get_library_extension(platform)
	lib_filename := get_library_filename(platform)

	// Download URL
	download_url := 'https://github.com/duckdb/duckdb/releases/download/${version}/libduckdb-${platform}.zip'
	println('🔗 Downloading from: ${download_url}')

	// Download the library
	zip_path := './thirdparty/libduckdb-${platform}.zip'
	download_file(download_url, zip_path) or { return error('Failed to download library: ${err}') }

	// Extract the library
	extract_library(zip_path, platform, lib_filename, lib_ext) or {
		return error('Failed to extract library: ${err}')
	}

	// Clean up
	os.rm(zip_path) or { println('⚠️  Warning: Could not remove zip file') }

	println('✅ Library installed successfully!')
}

fn get_library_extension(platform string) string {
	match platform {
		'windows-amd64' { return '.dll' }
		'osx-universal' { return '.dylib' }
		else { return '.so' }
	}
}

fn get_library_filename(platform string) string {
	match platform {
		'windows-amd64' { return 'duckdb.dll' }
		'osx-universal' { return 'libduckdb.dylib' }
		'linux-amd64' { return 'libduckdb.so' }
		'linux-arm64' { return 'libduckdb.so' }
		else { return 'libduckdb.so' }
	}
}

fn download_file(url string, path string) ! {
	println('⏳ Downloading...')

	// Use curl for reliable downloads with redirect support
	curl_cmd := 'curl -L -s -o "${path}" "${url}"'
	result := os.execute(curl_cmd)
	if result.exit_code != 0 {
		return error('curl download failed: ${result.output}')
	}

	// Verify the file was downloaded
	if !os.exists(path) {
		return error('Downloaded file not found')
	}

	file_info := os.stat(path) or { return error('Could not stat downloaded file') }
	if file_info.size < 1000 {
		return error('Downloaded file seems too small (${file_info.size} bytes)')
	}

	println('✅ Download completed (${file_info.size} bytes)')
}

fn extract_library(zip_path string, platform string, lib_filename string, lib_ext string) ! {
	println('📂 Extracting library files...')

	// For now, we'll use system unzip command
	// In a more sophisticated version, we could implement zip extraction in pure V
	unzip_cmd := 'unzip -j -o "${zip_path}" -d "./thirdparty/" "${lib_filename}" duckdb.h'

	result := os.execute(unzip_cmd)
	if result.exit_code != 0 {
		return error('Failed to extract library: ${result.output}')
	}

	// Determine target filename
	target_filename := 'libduckdb${lib_ext}'

	// Windows needs special handling - rename duckdb.dll to libduckdb.dll
	if platform == 'windows-amd64' && os.exists('./thirdparty/duckdb.dll') {
		os.mv('./thirdparty/duckdb.dll', './thirdparty/${target_filename}') or {
			return error('Failed to rename Windows library: ${err}')
		}
	}

	// Copy to src/thirdparty for tests
	os.cp('./thirdparty/${target_filename}', './src/thirdparty/${target_filename}') or {
		return error('Failed to copy library to src/thirdparty: ${err}')
	}
	os.cp('./thirdparty/duckdb.h', './src/thirdparty/duckdb.h') or {
		return error('Failed to copy header to src/thirdparty: ${err}')
	}

	// Create symlink in root directory (Unix-like systems only)
	if platform != 'windows-amd64' {
		if !os.exists('./${target_filename}') {
			os.symlink('./thirdparty/${target_filename}', './${target_filename}') or {
				println('⚠️  Warning: Could not create symlink (this is normal on Windows)')
			}
		}
	}

	println('✅ Library extracted and installed')
}

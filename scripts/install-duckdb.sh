#!/bin/bash

# DuckDB Library Auto-Installer for vduckdb
# Automatically detects OS and architecture, downloads the appropriate library

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect OS and architecture
detect_platform() {
    OS=$(uname -s)
    ARCH=$(uname -m)
    
    print_status "Detected OS: ${OS}, Architecture: ${ARCH}"
    
    # Map OS and architecture to DuckDB distribution
    if [ "${OS}" = "Linux" ]; then
        if [ "${ARCH}" = "x86_64" ] || [ "${ARCH}" = "amd64" ]; then
            DIST="linux-amd64"
            LIB_EXT=".so"
        elif [ "${ARCH}" = "aarch64" ] || [ "${ARCH}" = "arm64" ]; then
            DIST="linux-arm64"
            LIB_EXT=".so"
        else
            print_error "Unsupported Linux architecture: ${ARCH}"
            exit 1
        fi
    elif [ "${OS}" = "Darwin" ]; then
        if [ "${ARCH}" = "x86_64" ]; then
            DIST="osx-universal"
            LIB_EXT=".dylib"
        elif [ "${ARCH}" = "arm64" ]; then
            DIST="osx-universal"
            LIB_EXT=".dylib"
        else
            print_error "Unsupported macOS architecture: ${ARCH}"
            exit 1
        fi
    elif [[ "${OS}" == MINGW* ]] || [[ "${OS}" == MSYS* ]] || [[ "${OS}" == CYGWIN* ]]; then
        DIST="windows-amd64"
        LIB_EXT=".dll"
    else
        print_error "Unsupported operating system: ${OS}"
        exit 1
    fi
    
    print_status "Using distribution: ${DIST}"
}

# Function to get latest DuckDB version
get_latest_version() {
    print_status "Fetching latest DuckDB version..."
    
    # Try to get version from DuckDB's latest version endpoint
    if command -v curl >/dev/null 2>&1; then
        LATEST_VERSION=$(curl -s https://duckdb.org/data/latest_stable_version.txt 2>/dev/null || echo "")
        # Add 'v' prefix if it's missing
        if [ -n "${LATEST_VERSION}" ] && [[ ! "${LATEST_VERSION}" =~ ^v ]]; then
            LATEST_VERSION="v${LATEST_VERSION}"
        fi
    fi
    
    # Fallback: try GitHub API (without jq dependency)
    if [ -z "${LATEST_VERSION}" ]; then
        print_warning "Could not fetch from DuckDB endpoint, trying GitHub API..."
        if command -v curl >/dev/null 2>&1; then
            LATEST_VERSION=$(curl -s https://api.github.com/repos/duckdb/duckdb/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
        fi
    fi
    
    # Final fallback: use a known recent version
    if [ -z "${LATEST_VERSION}" ]; then
        print_warning "Could not fetch latest version, using fallback version v1.3.2"
        LATEST_VERSION="v1.3.2"
    fi
    
    print_success "Latest DuckDB version: ${LATEST_VERSION}"
}

# Function to download and install library
download_library() {
    local version=$1
    local dist=$2
    local lib_ext=$3
    
    # Create directories
    mkdir -p ./thirdparty
    mkdir -p ./src/thirdparty
    
    # Determine library filename based on platform
    if [ "${dist}" = "windows-amd64" ]; then
        LIB_FILENAME="duckdb.dll"
        TARGET_FILENAME="libduckdb.dll"
    else
        LIB_FILENAME="libduckdb${lib_ext}"
        TARGET_FILENAME="libduckdb${lib_ext}"
    fi
    
    # Download URL
    DOWNLOAD_URL="https://github.com/duckdb/duckdb/releases/download/${version}/libduckdb-${dist}.zip"
    
    print_status "Downloading DuckDB library from: ${DOWNLOAD_URL}"
    
    # Download the library
    if command -v curl >/dev/null 2>&1; then
        curl -L --fail --location --progress-bar -o "./thirdparty/libduckdb-${dist}.zip" "${DOWNLOAD_URL}"
    else
        print_error "curl is required but not installed. Please install curl and try again."
        exit 1
    fi
    
    if [ ! -f "./thirdparty/libduckdb-${dist}.zip" ]; then
        print_error "Failed to download library"
        exit 1
    fi
    
    print_status "Extracting library files..."
    
    # Extract the library and header
    if command -v unzip >/dev/null 2>&1; then
        unzip -j -o "./thirdparty/libduckdb-${dist}.zip" -d "./thirdparty/" "${LIB_FILENAME}" duckdb.h
    else
        print_error "unzip is required but not installed. Please install unzip and try again."
        exit 1
    fi
    
    # Rename the library to standard name
    if [ -f "./thirdparty/${LIB_FILENAME}" ]; then
        mv "./thirdparty/${LIB_FILENAME}" "./thirdparty/${TARGET_FILENAME}"
    fi
    
    # Copy to src/thirdparty for tests
    cp "./thirdparty/${TARGET_FILENAME}" "./src/thirdparty/"
    cp "./thirdparty/duckdb.h" "./src/thirdparty/"
    
    # Create symlink in root directory
    if [ ! -L "./${TARGET_FILENAME}" ]; then
        ln -sf "./thirdparty/${TARGET_FILENAME}" "./${TARGET_FILENAME}"
    fi
    
    # Clean up
    rm "./thirdparty/libduckdb-${dist}.zip"
    
    print_success "Library installed successfully!"
    print_status "Library location: ./thirdparty/${TARGET_FILENAME}"
    print_status "Header location: ./thirdparty/duckdb.h"
    print_status "Symlink created: ./${TARGET_FILENAME}"
}

# Function to check if library is already installed and up-to-date
check_existing_library() {
    if [ -f "./thirdparty/libduckdb${LIB_EXT}" ] && [ -f "./thirdparty/duckdb.h" ]; then
        print_status "DuckDB library already exists in ./thirdparty/"
        
        # Check if we can determine the version of existing library
        if command -v strings >/dev/null 2>&1 && [ -f "./thirdparty/libduckdb${LIB_EXT}" ]; then
            EXISTING_VERSION=$(strings "./thirdparty/libduckdb${LIB_EXT}" | grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" | head -1 || echo "")
            if [ -n "${EXISTING_VERSION}" ]; then
                print_status "Existing library version: ${EXISTING_VERSION}"
                if [ "${EXISTING_VERSION}" = "${LATEST_VERSION}" ]; then
                    print_success "Library is already up-to-date!"
                    exit 0
                else
                    print_warning "Library is outdated (${EXISTING_VERSION} vs ${LATEST_VERSION})"
                fi
            fi
        fi
    fi
}

# Main execution
main() {
    print_status "Starting DuckDB library installation..."
    
    # Check dependencies
    if ! command -v curl >/dev/null 2>&1; then
        print_error "curl is required but not installed. Please install curl and try again."
        exit 1
    fi
    
    if ! command -v unzip >/dev/null 2>&1; then
        print_error "unzip is required but not installed. Please install unzip and try again."
        exit 1
    fi
    
    # Detect platform
    detect_platform
    
    # Get latest version
    get_latest_version
    
    # Check existing library
    check_existing_library
    
    # Download and install
    download_library "${LATEST_VERSION}" "${DIST}" "${LIB_EXT}"
    
    print_success "DuckDB library installation completed successfully!"
    print_status "You can now run 'make test' to verify the installation"
}

# Run main function
main "$@"

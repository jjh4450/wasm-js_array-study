#!/bin/bash
(
# Define the default package manager
installer="pnpm"
# Specify the project directories
wasm_dir="./wasm-js-array-study"
dir="./test_web"

# Function to print usage information
usage() {
    echo "Usage: $0 [-b <y/n>]"
    echo "  -b    Build the wasm module (y/n)"
    exit 1
}

# Default build option
build_wasm=""

# Parse command-line options
while getopts "b:" opt; do
    case "$opt" in
        b) build_wasm=$OPTARG;;
        \?) usage;;
    esac
done

# Check if 'pnpm' is available
if ! command -v $installer &> /dev/null; then
    echo "pnpm is not installed."
    read -p "Would you like to proceed with npm instead? (y/n) " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        installer="npm"
    else
        echo "Please install pnpm."
        echo "Visit https://pnpm.io/installation for installation instructions."
        exit 126
    fi
fi

echo "Using $installer as the package manager."

# If no build option provided, ask user
if [ -z "$build_wasm" ]; then
    read -p "Would you like to build wasm module? (y/n) " build_wasm
fi

# Build wasm module if requested
if [[ $build_wasm =~ ^[Yy]$ ]]; then
    echo "Building wasm module..."
    source ./wasm_build.sh
    if [ $? -ne 0 ]; then
        echo "Build failed."
        exit 1
    fi
fi

# Change to the project directory
cd $dir

# Install dependencies if necessary
if [[ $installer == "npm" && -d "node_modules" && $(ls -A node_modules) ]]; then
    read -p "Would you like to reinstall the dependencies? (y/n) " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo "Reinstalling dependencies..."
        $installer install
    fi
else
    echo "Installing dependencies..."
    $installer install
fi

# Start the project
echo "Starting the project..."
$installer run dev

)
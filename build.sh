#!/usr/bin/env bash

# Exit on any error
set -e

# Check if cmake is available
if ! command -v cmake &>/dev/null; then
    echo "ERROR: cmake is not installed or not in PATH"
    echo "Please install cmake: sudo apt-get install cmake (Ubuntu/Debian)"
    exit 1
fi

# Check if build tools are available
if ! command -v make &>/dev/null && ! command -v ninja &>/dev/null; then
    echo "ERROR: No build system found (make or ninja)"
    echo "Please install build tools: sudo apt-get install build-essential (Ubuntu/Debian)"
    exit 1
fi

[ -d meshoptimizer ] || git clone https://github.com/zeux/meshoptimizer --depth=1

# Set source and build directories
SOURCE_DIR="./meshoptimizer"
BINARIES_DIR="./build"
if [ $(uname -s) = 'Darwin' ]; then
    BINARIES_DIR="./build"
    NCORE=$(sysctl -n hw.ncpu)
    LIB_EXT=darwin
else
    NCORE=$(nproc)
    LIB_EXT=linux
fi

# Configure the build with cmake
echo "Configuring build..."
cmake "$SOURCE_DIR" -S "$SOURCE_DIR" -B "$BINARIES_DIR" -DCMAKE_BUILD_TYPE=Release

# Build the project
echo "Building project..."
cmake --build "$BINARIES_DIR" --config Release -j$NCORE

cp $BINARIES_DIR/libmeshoptimizer.a ./meshoptimizer.$LIB_EXT.a

echo "Build completed successfully!"

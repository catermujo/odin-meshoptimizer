#!/usr/bin/env bash

set -euo pipefail

clone_at_revision() {
    local dir="$1"
    local revision="$2"
    local remote="$3"
    shift 3
    [ -d "$dir" ] && return
    git clone "$@" "$remote" "$dir"
    if ! git -C "$dir" checkout --detach "$revision"; then
        git -C "$dir" fetch origin "$revision"
        git -C "$dir" checkout --detach FETCH_HEAD
    fi
    if [ -f "$dir/.gitmodules" ]; then
        git -C "$dir" submodule update --init --recursive
    fi
}

clone_at_revision meshoptimizer 3c1647e4aeb2cbdca6f11d4f4f4f694da2ff49a4 https://github.com/zeux/meshoptimizer --depth=1

linux_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "linux_x64" ;;
        aarch64 | arm64) echo "linux_arm64" ;;
        *) echo "linux_$(uname -m)" ;;
    esac
}

darwin_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "darwin_x64" ;;
        aarch64 | arm64) echo "darwin_arm64" ;;
        *) echo "darwin_$(uname -m)" ;;
    esac
}

SOURCE_DIR="./meshoptimizer"
if [ "$(uname -s)" = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
    ARCH_DIR=$(darwin_arch_dir)
    LIB_EXT=darwin
else
    CPU=$(nproc)
    ARCH_DIR=$(linux_arch_dir)
    LIB_EXT=linux
fi
BINARIES_DIR="./build_$ARCH_DIR"
mkdir -p "./$ARCH_DIR"

echo "Configuring build..."
cmake -S "$SOURCE_DIR" -B "$BINARIES_DIR" -DCMAKE_BUILD_TYPE=Release

echo "Building project..."
cmake --build "$BINARIES_DIR" --config Release -j"$CPU"

cp "$BINARIES_DIR/libmeshoptimizer.a" "./$ARCH_DIR/meshoptimizer.$LIB_EXT.a"

echo "Build completed successfully!"

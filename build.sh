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

BASE="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$BASE/meshoptimizer"
if [ "$(uname -s)" = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
    ARCH_DIR=$(darwin_arch_dir)
    LIB_EXT=darwin
    SHARED_EXT=dylib
else
    CPU=$(nproc)
    ARCH_DIR=$(linux_arch_dir)
    LIB_EXT=linux
    SHARED_EXT=so
fi
STATIC_BUILD_DIR="$BASE/build_static_$ARCH_DIR"
SHARED_BUILD_DIR="$BASE/build_shared_$ARCH_DIR"
OUTPUT_DIR="$BASE/$ARCH_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Configuring static build..."
cmake -S "$SOURCE_DIR" -B "$STATIC_BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DMESHOPT_BUILD_SHARED_LIBS=OFF

echo "Building static project..."
cmake --build "$STATIC_BUILD_DIR" --config Release -j"$CPU"

echo "Configuring shared build..."
cmake -S "$SOURCE_DIR" -B "$SHARED_BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DMESHOPT_BUILD_SHARED_LIBS=ON

echo "Building shared project..."
cmake --build "$SHARED_BUILD_DIR" --config Release -j"$CPU"

cp "$STATIC_BUILD_DIR/libmeshoptimizer.a" "$OUTPUT_DIR/meshoptimizer.$LIB_EXT.a"
cp "$SHARED_BUILD_DIR/libmeshoptimizer.$SHARED_EXT" "$OUTPUT_DIR/libmeshoptimizer.$SHARED_EXT"

echo "Build completed successfully!"

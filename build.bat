@echo off

setlocal EnableDelayedExpansion

pushd bindgen

if not exist meshoptimizer\NUL (
    echo cu
    git clone https://github.com/zeux/meshoptimizer --depth=1
)

set binaries_dir=build\windows

echo Configuring build...
cmake -A x64 -S meshoptimizer -B %binaries_dir%

echo Building project...
cmake --build %binaries_dir% --config Release

copy /y %binaries_dir%\Release\meshoptimizer.lib ..\

popd bindgen

echo Build completed successfully!




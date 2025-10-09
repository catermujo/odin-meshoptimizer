@echo off

setlocal EnableDelayedExpansion

if not exist meshoptimizer\NUL (
    git clone https://github.com/zeux/meshoptimizer --depth=1
)

set binaries_dir=build

echo Configuring build...
cmake -A x64 -S meshoptimizer -B %binaries_dir%

echo Building project...
cmake --build %binaries_dir% --config Release

copy /y %binaries_dir%\Release\meshoptimizer.lib .\

echo Build completed successfully!

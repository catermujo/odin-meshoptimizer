@echo off

setlocal EnableDelayedExpansion

set "VENDOR_WINDOWS_ARCH=%VSCMD_ARG_TGT_ARCH%"
if not defined VENDOR_WINDOWS_ARCH set "VENDOR_WINDOWS_ARCH=%PROCESSOR_ARCHITECTURE%"
if /I "%VENDOR_WINDOWS_ARCH%"=="AMD64" set "VENDOR_WINDOWS_ARCH=x64"
if /I "%VENDOR_WINDOWS_ARCH%"=="ARM64" set "VENDOR_WINDOWS_ARCH=arm64"
if /I "%VENDOR_WINDOWS_ARCH%"=="X86" set "VENDOR_WINDOWS_ARCH=x64"
set "BASE=%~dp0"
set output_dir=windows_%VENDOR_WINDOWS_ARCH%

if not exist meshoptimizer (
    git clone --revision 3c1647e4aeb2cbdca6f11d4f4f4f694da2ff49a4 https://github.com/zeux/meshoptimizer --depth=1
)

set binaries_dir=build_%VENDOR_WINDOWS_ARCH%

echo Configuring build...
cmake -A %VENDOR_WINDOWS_ARCH% -S meshoptimizer -B %binaries_dir%

echo Building project...
cmake --build %binaries_dir% --config Release

if not exist "%BASE%%output_dir%" mkdir "%BASE%%output_dir%"
copy /y %binaries_dir%\Release\meshoptimizer.lib "%BASE%%output_dir%\meshoptimizer.lib"

echo Build completed successfully!

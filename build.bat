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

set static_build_dir=build_static_%VENDOR_WINDOWS_ARCH%
set shared_build_dir=build_shared_%VENDOR_WINDOWS_ARCH%

echo Configuring static build...
cmake -A %VENDOR_WINDOWS_ARCH% -S meshoptimizer -B %static_build_dir% -DMESHOPT_BUILD_SHARED_LIBS=OFF || exit /b 1

echo Building static project...
cmake --build %static_build_dir% --config Release || exit /b 1

echo Configuring shared build...
cmake -A %VENDOR_WINDOWS_ARCH% -S meshoptimizer -B %shared_build_dir% -DMESHOPT_BUILD_SHARED_LIBS=ON || exit /b 1

echo Building shared project...
cmake --build %shared_build_dir% --config Release || exit /b 1

if not exist "%BASE%%output_dir%" mkdir "%BASE%%output_dir%"
copy /y %static_build_dir%\Release\meshoptimizer.lib "%BASE%%output_dir%\meshoptimizer.lib" || exit /b 1
copy /y %shared_build_dir%\Release\meshoptimizer.lib "%BASE%%output_dir%\meshoptimizer_shared.lib" || exit /b 1
copy /y %shared_build_dir%\Release\meshoptimizer.dll "%BASE%%output_dir%\meshoptimizer.dll" || exit /b 1

echo Build completed successfully!

# odin-meshoptimizer

Binding for https://github.com/zeux/meshoptimizer

`build.sh` and `build.bat` produce both static and shared libraries. Select Darwin linkage with
`-define:MESHOPT_LINK=static` or `-define:MESHOPT_LINK=shared`; static remains the standalone default and the checked-in
Windows and Linux artifacts remain static until their shared binaries are regenerated on those platforms.

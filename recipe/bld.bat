@echo on

mkdir builddir

:: check if clang-cl is on path as required
clang-cl.exe --version
if %ERRORLEVEL% neq 0 exit 1

:: check flang-new output
flang-new.exe --version

set
:: set compilers to clang-cl
set "CC=clang-cl"
set "CXX=clang-cl"

:: flang 17 still uses "temporary" name
set "FC=flang-new"

:: set up clang-cl correctly, see
:: https://github.com/conda-forge/clang-win-activation-feedstock/blob/main/recipe/activate-clang_win-64.sh
set "CPPFLAGS=-D_CRT_SECURE_NO_WARNINGS -D_MT -D_DLL --target=x86_64-pc-windows-msvc -Xclang --dependent-lib=msvcrt -fuse-ld=lld"
set "FFLAGS=-D_CRT_SECURE_NO_WARNINGS -D_MT -D_DLL --target=x86_64-pc-windows-msvc -nostdlib"
set "LDFLAGS=--target=x86_64-pc-windows-msvc -nostdlib -Xclang --dependent-lib=msvcrt -fuse-ld=lld"
set "LDFLAGS=%LDFLAGS% -Wl,-defaultlib:%LIBRARY_PREFIX%/lib/clang/17.0.0/lib/windows/clang_rt.builtins-x86_64.lib"

:: debug
echo CPPFLAGS=%CPPFLAGS%
echo FFLAGS=%FFLAGS%
echo LDFLAGS=%LDFLAGS%

:: see explanation here:
:: https://github.com/conda-forge/scipy-feedstock/pull/253#issuecomment-1732578945
set "MESON_RSP_THRESHOLD=320000"

:: -wnx flags mean: --wheel --no-isolation --skip-dependency-check
%PYTHON% -m build -w -n -x ^
    -Cbuilddir=builddir ^
    -Csetup-args=-Dblas=blas ^
    -Csetup-args=-Dlapack=lapack ^
    -Csetup-args=-Dfortran_std=none ^
    -Csetup-args=-Duse-g77-abi=true
if %ERRORLEVEL% neq 0 (type builddir\meson-logs\meson-log.txt && exit 1)

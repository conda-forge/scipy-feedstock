@echo on

mkdir builddir

:: check if clang-cl is on path as required
clang-cl.exe --version
if %ERRORLEVEL% neq 0 exit 1

:: set compilers to clang-cl
set "CC=clang-cl"
set "CXX=clang-cl"
set "CC_LD=lld"
set "CXX_LD=lld"

:: flang 17 still uses "temporary" name
set "FC=flang-new"
set "FC_LD=lld"

set "LDFLAGS=%LDFLAGS% -Wl,-Lucrt"

:: -wnx flags mean: --wheel --no-isolation --skip-dependency-check
%PYTHON% -m build -w -n -x ^
    -Cbuilddir=builddir ^
    -Csetup-args=-Dblas=blas ^
    -Csetup-args=-Dlapack=lapack ^
    -Csetup-args=-Dfortran_std=none ^
    -Csetup-args=-Duse-g77-abi=true
if %ERRORLEVEL% neq 0 exit 1

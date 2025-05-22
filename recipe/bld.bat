@echo on
setlocal enabledelayedexpansion

mkdir builddir

:: check if clang-cl is on path as required
clang-cl.exe --version
if %ERRORLEVEL% neq 0 exit 1

:: set compilers to clang-cl
set "CC=clang-cl"
set "CXX=clang-cl"

:: see explanation here:
:: https://github.com/conda-forge/scipy-feedstock/pull/253#issuecomment-1732578945
set "MESON_RSP_THRESHOLD=320000"

:: -wnx flags mean: --wheel --no-isolation --skip-dependency-check
%PYTHON% -m build -w -n -x ^
    -Cbuilddir=builddir ^
    -Cinstall-args=--tags=runtime,python-runtime,devel ^
    -Csetup-args=-Dblas=blas ^
    -Csetup-args=-Dcpp_std=c++17 ^
    -Csetup-args=-Dlapack=lapack ^
    -Csetup-args=-Dfortran_std=none ^
    -Csetup-args=-Duse-system-libraries ^
    -Csetup-args=-Duse-g77-abi=true
if %ERRORLEVEL% neq 0 (type builddir\meson-logs\meson-log.txt && exit 1)

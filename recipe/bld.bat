@echo on

mkdir builddir

:: unset LD from compiler activation
set "LD="
:: try to use linker that knows it cannot use rsp's, see
:: https://github.com/conda-forge/meson-feedstock/pull/86
set "CC_LD=ld.lld"
set "CXX_LD=ld.lld"

:: flang 17 still uses "temporary" name
set "FC=flang-new"
set "FC_LD=ld.lld"

set "CFLAGS=%CFLAGS% -std=gnu99"

:: see explanation here:
:: https://github.com/conda-forge/scipy-feedstock/pull/253#issuecomment-1732578945
set "MESON_RSP_THRESHOLD=32000"

:: -wnx flags mean: --wheel --no-isolation --skip-dependency-check
%PYTHON% -m build -w -n -x ^
    -Cbuilddir=builddir ^
    -Csetup-args=-Dblas=blas ^
    -Csetup-args=-Dlapack=lapack ^
    -Csetup-args=-Dfortran_std=none ^
    -Csetup-args=-Duse-g77-abi=true
if %ERRORLEVEL% neq 0 exit 1

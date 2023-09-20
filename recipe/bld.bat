@echo on

mkdir builddir

:: flang 17 still uses "temporary" name
cp %RECIPE_DIR%\flang-wrapper.bat %LIBRARY_PREFIX%\bin
set "FC=flang-wrapper.bat"

set "CFLAGS=%CFLAGS% -std=gnu99"

:: -wnx flags mean: --wheel --no-isolation --skip-dependency-check
%PYTHON% -m build -w -n -x ^
    -Cbuilddir=builddir ^
    -Csetup-args=-Dblas=blas ^
    -Csetup-args=-Dlapack=lapack ^
    -Csetup-args=-Dfortran_std=none ^
    -Csetup-args=-Duse-g77-abi=true
if %ERRORLEVEL% neq 0 exit 1

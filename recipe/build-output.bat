@echo on
setlocal enabledelayedexpansion

:: for reason see source section in meta.yaml & below
cd base

REM these are done automatically for openblas by numpy.distutils, but
REM not for our blas libraries
echo %LIBRARY_LIB%\blas.lib > %LIBRARY_LIB%\blas.fobjects
echo %LIBRARY_LIB%\blas.lib > %LIBRARY_LIB%\blas.cobjects
echo %LIBRARY_LIB%\cblas.lib > %LIBRARY_LIB%\cblas.fobjects
echo %LIBRARY_LIB%\cblas.lib > %LIBRARY_LIB%\cblas.cobjects
echo %LIBRARY_LIB%\lapack.lib > %LIBRARY_LIB%\lapack.fobjects
echo %LIBRARY_LIB%\lapack.lib > %LIBRARY_LIB%\lapack.cobjects

REM Set a few environment variables that are not set due to
REM https://github.com/conda/conda-build/issues/3993
set PIP_NO_BUILD_ISOLATION=True
set PIP_NO_DEPENDENCIES=True
set PIP_IGNORE_INSTALLED=True
set PIP_NO_INDEX=True
set PYTHONDONTWRITEBYTECODE=True

REM Use the G77 ABI wrapper everywhere so that the underlying blas implementation
REM can have a G77 ABI (currently only MKL)
set SCIPY_USE_G77_ABI_WRAPPER=1

REM Need to get numpy include paths, which also requires the one for Python
FOR /F "tokens=* USEBACKQ" %%F IN (`python -c "import numpy; print(numpy.get_include())"`) DO (
    SET "NP_INC=%%F"
)
FOR /F "tokens=* USEBACKQ" %%F IN (`python -c "import sysconfig; print(sysconfig.get_path('include'))"`) DO (
    SET "PY_INC=%%F"
)

REM This builds a Fortran file which calls a C function, but numpy.distutils
REM creates an isolated DLL for these fortran functions and therefore it doesn't
REM see these C functions. workaround this by compiling it ourselves and
REM sneaking it with the blas libraries
REM TODO: rewrite wrap_g77_abi.f with iso_c_binding when the compiler supports it
cl.exe /I%NP_INC% /I%PY_INC% scipy\_build_utils\src\wrap_g77_abi_c.c -c /MD
if %ERRORLEVEL% neq 0 exit 1
echo. > scipy\_build_utils\src\wrap_g77_abi_c.c
echo %SRC_DIR%\base\wrap_g77_abi_c.obj >> %LIBRARY_LIB%\lapack.fobjects
echo %SRC_DIR%\base\wrap_g77_abi_c.obj >> %LIBRARY_LIB%\lapack.cobjects

REM Add a file to load the fortran wrapper libraries in scipy/.libs
del scipy\_distributor_init.py
if %ERRORLEVEL% neq 0 exit 1
copy %RECIPE_DIR%\_distributor_init.py scipy\
if %ERRORLEVEL% neq 0 exit 1

REM check if clang-cl is on path as required
clang-cl.exe --version
if %ERRORLEVEL% neq 0 exit 1

REM set compilers to clang-cl
set "CC=clang-cl"
set "CXX=clang-cl"

REM clang-cl & gfortran use different LDFLAGS; unset it
set "LDFLAGS="
REM don't add d1trimfile option because clang doesn't recognize it.
set "SRC_DIR="

%PYTHON% _setup.py install --single-version-externally-managed --record=record.txt
if %ERRORLEVEL% neq 0 exit 1

REM make sure these aren't packaged
del %LIBRARY_LIB%\blas.fobjects
del %LIBRARY_LIB%\blas.cobjects
del %LIBRARY_LIB%\cblas.fobjects
del %LIBRARY_LIB%\cblas.cobjects
del %LIBRARY_LIB%\lapack.fobjects
del %LIBRARY_LIB%\lapack.cobjects

FOR /F "tokens=* USEBACKQ" %%F IN (`python -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))"`) DO (
    SET EXT_SUFFIX=%%F
)

REM delete tests from baseline output "scipy"
if "%PKG_NAME%"=="scipy" (
    REM folders in test_folders_to_delete.txt are relative to %SP_DIR%\scipy
    REM the contents of this are validated in build-output.sh
    for /F %%f in (%RECIPE_DIR%\test_folders_to_delete.txt) do (
        set "g=%%f"
        rmdir /s /q %SP_DIR%\scipy\!g:/=\!
    )
    REM additionally delete folder not found on linux
    rmdir /s /q %SP_DIR%\scipy\_build_utils\tests

    REM same for test_libraries_to_delete.txt
    for /F %%f in (%RECIPE_DIR%\test_libraries_to_delete.txt) do (
        set "g=%%f"
        REM replace suffix marker with python ABI
        set "h=!g:SUFFIX_MARKER=%EXT_SUFFIX%!"
        del /f %SP_DIR%\scipy\!h:/=\!
    )

    REM copy "test" with informative error message into installation
    copy %RECIPE_DIR%\test_conda_forge_packaging.py %SP_DIR%\scipy\_lib

    REM hard-reset %SRC_DIR%\base to original state; see prep in bld.bat
    cd ..
    rmdir /s /q base
    REM both `move` and `robocopy` may spuriously fail to copy for some inane reason;
    REM use `robocopy` because it should fail less than `move`, and it provides a log.
    REM return code 1 means success, for anything else show log (though we'll know
    REM anyway, because if the copy fails, compilation for `scipy-tests` will break).
    (robocopy backup base /E /MOVE >copylog) || if !ERRORLEVEL! neq 1 type copylog
)

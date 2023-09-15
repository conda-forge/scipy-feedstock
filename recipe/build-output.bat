@echo on

REM Set a few environment variables that are not set due to
REM https://github.com/conda/conda-build/issues/3993
set PIP_NO_BUILD_ISOLATION=True
set PIP_NO_DEPENDENCIES=True
set PIP_IGNORE_INSTALLED=True
set PIP_NO_INDEX=True
set PYTHONDONTWRITEBYTECODE=True

:: need to use force to reinstall the tests the second time
:: (otherwise pip thinks the package is installed already)
pip install dist\scipy*.whl --force-reinstall

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

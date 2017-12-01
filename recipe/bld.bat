REM Use OpenBLAS with 1 thread only as it seems to be using too many
REM on the CIs apparently.
set OPENBLAS_NUM_THREADS=1
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_amd64
python setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1

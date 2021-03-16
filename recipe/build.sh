#!/bin/bash

# Use the G77 ABI wrapper everywhere so that the underlying blas implementation
# can have a G77 ABI (currently only MKL)
export SCIPY_USE_G77_ABI_WRAPPER=1

# When cross-compiling to osx-arm64, certain fortran optimizations cause seg-faults
# https://github.com/iains/gcc-darwin-arm64/issues/44
if [[ $target_platform == "osx-arm64" ]]; then
  export FFLAGS="${FFLAGS} -fno-tree-loop-vectorize -fno-tree-slp-vectorize"
fi

if [[ "$python_impl" == "pypy" && "$target_platform" == "linux-ppc64le" ]]; then
    $PYTHON setup.py install --single-version-externally-managed --record=record.txt
else
    $PYTHON -m pip install . -vv
fi

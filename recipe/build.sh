#!/bin/bash

# Use the G77 ABI wrapper everywhere so that the underlying blas implementation
# can have a G77 ABI (currently only MKL)
export SCIPY_USE_G77_ABI_WRAPPER=1

if [[ "$target_platform" == linux* ]]; then
    export CFLAGS="$CFLAGS -fno-optimize-sibling-calls"
    export CXXFLAGS="$CXXFLAGS -fno-optimize-sibling-calls"
    export CPPFLAGS="$CPPFLAGS -fno-optimize-sibling-calls"
    export FFLAGS="$FFLAGS -fno-optimize-sibling-calls"
fi

if [[ "$python_impl" == "pypy" && "$target_platform" == "linux-ppc64le" ]]; then
    python setup.py install --single-version-externally-managed --record=record.txt
else
    pip install . -vv
fi

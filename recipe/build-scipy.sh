#!/bin/bash

# Use the G77 ABI wrapper everywhere so that the underlying blas implementation
# can have a G77 ABI (currently only MKL)
export SCIPY_USE_G77_ABI_WRAPPER=1

# Set a few environment variables that are not set due to
# https://github.com/conda/conda-build/issues/3993
export PIP_NO_BUILD_ISOLATION=False
export PIP_NO_DEPENDENCIES=True
export PIP_IGNORE_INSTALLED=True
export PIP_NO_INDEX=True
export PYTHONDONTWRITEBYTECODE=True

if [[ "$python_impl" == "pypy" && "$target_platform" == "linux-ppc64le" ]]; then
    $PYTHON setup.py install --single-version-externally-managed --record=record.txt
else
    $PYTHON -m pip install . -vv
fi

if [[ "$PKG_NAME" == "scipy" ]]; then
  find ${SP_DIR}/scipy -name tests -type d | xargs rm -r
fi

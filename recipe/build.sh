#!/bin/bash

set -x

# Use the G77 ABI wrapper everywhere so that the underlying blas implementation
# can have a G77 ABI (currently only MKL)
export SCIPY_USE_G77_ABI_WRAPPER=1

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

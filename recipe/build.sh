#!/bin/bash
set -ex

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -x  -Csetup-args=-Dblas=blas -Csetup-args=-Dlapack=lapack -Csetup-args=-Duse-g77-abi=true
pip install dist/scipy*.whl

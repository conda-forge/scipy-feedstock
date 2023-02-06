#!/bin/bash
set -ex

mkdir builddir

# need to run meson first for cross-compilation case
meson ${MESON_ARGS} builddir

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -x \
    -Cbuilddir=builddir \
    -Csetup-args=-Dblas=blas \
    -Csetup-args=-Dlapack=lapack \
    -Csetup-args=-Duse-g77-abi=true
pip install dist/scipy*.whl

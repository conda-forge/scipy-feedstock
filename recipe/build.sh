#!/bin/bash
set -ex

mkdir builddir

# need to run meson first for cross-compilation case
meson ${MESON_ARGS} \
    -Dblas=blas \
    -Dlapack=lapack \
    -Duse-g77-abi=true \
    builddir || (cat builddir/meson-logs/meson-log.txt && exit 1)

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -x -Cbuilddir=builddir
pip install dist/scipy*.whl

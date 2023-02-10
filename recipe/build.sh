#!/bin/bash
set -ex

mkdir builddir

# for some reason empty on linux
export MESON_ARGS=${MESON_ARGS:---prefix=${PREFIX} --libdir=lib}

if [[ "$target_platform" == "linux-aarch64" ]]; then
    cp $RECIPE_DIR/meson_cross_aarch64.txt ${BUILD_PREFIX}/meson_cross_file.txt
    export MESON_ARGS="${MESON_ARGS} --cross-file=${BUILD_PREFIX}/meson_cross_file.txt"
elif [[ "$target_platform" == "linux-ppc64le" ]]; then
    cp $RECIPE_DIR/meson_cross_ppc64le.txt ${BUILD_PREFIX}/meson_cross_file.txt
    export MESON_ARGS="${MESON_ARGS} --cross-file=${BUILD_PREFIX}/meson_cross_file.txt"
fi

# debug
cat ${BUILD_PREFIX}/meson_cross_file.txt || true

# need to run meson first for cross-compilation case
meson setup ${MESON_ARGS} \
    -Dblas=blas \
    -Dlapack=lapack \
    -Duse-g77-abi=true \
    builddir || (cat builddir/meson-logs/meson-log.txt && exit 1)

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -x -Cbuilddir=builddir
pip install dist/scipy*.whl

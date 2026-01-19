#!/bin/bash
set -ex

if [[ "$PKG_NAME" == "scipy" ]]; then
    # install wheel from build.sh
    pip install dist/scipy*.whl

    if [[ "$is_freethreading" == "true" ]]; then
        # work around https://github.com/conda/conda-build/issues/5563
        cp $RECIPE_DIR/test_conda_forge_packaging.py $PREFIX/lib/python${PY_VER}t/site-packages/scipy/_lib
    else
        # copy "test" with informative error message into installation
        cp $RECIPE_DIR/test_conda_forge_packaging.py $SP_DIR/scipy/_lib
    fi

    # clean up dist folder for building tests
    rm -rf dist
else
    # copy of build.sh, except different build tags; instead of using the
    # same script (lightly templated on tags) per output, we keep the
    # global build to reuse the cache when building the tests

    # need to rename project as well; for more details see
    # https://scipy.github.io/devdocs/building/redistributable_binaries.html
    sed -i "s:name = \"scipy\":name = \"scipy-tests\":g" pyproject.toml

    if [[ $build_platform != $target_platform ]]; then
        # see build.sh
        echo "[binaries]"                                   > $SRC_DIR/scipy_cross_file.txt
        echo "numpy-config = '${PREFIX}/bin/numpy-config'" >> $SRC_DIR/scipy_cross_file.txt
        export MESON_ARGS="$MESON_ARGS --cross-file=$SRC_DIR/scipy_cross_file.txt"
    fi

    # -wnx flags mean: --wheel --no-isolation --skip-dependency-check
    $PYTHON -m build -w -n -x \
        -Cbuilddir=builddir \
        -Cinstall-args=--tags=tests \
        -Csetup-args=-Dblas=blas \
        -Csetup-args=-Dlapack=lapack \
        -Csetup-args=-Duse-g77-abi=true \
        -Csetup-args=${MESON_ARGS// / -Csetup-args=} \
        || (cat builddir/meson-logs/meson-log.txt && exit 1)

    pip install dist/scipy*.whl
fi

#!/bin/bash

if [[ -f $BUILD_PREFIX/bin/python ]]; then
  $BUILD_PREFIX/bin/python -m crossenv $PREFIX/bin/python \
      --sysroot $CONDA_BUILD_SYSROOT \
      --without-pip $BUILD_PREFIX/venv \
      --sysconfigdata-file $PREFIX/lib/python$PY_VER/${_CONDA_PYTHON_SYSCONFIGDATA_NAME}.py
  cp $BUILD_PREFIX/venv/cross/bin/python $PREFIX/bin/python
  rm -rf $BUILD_PREFIX/venv/cross
  if [[ -f $PREFIX/lib/python$PY_VER/site-packages/numpy/distutils/site.cfg ]]; then
    rsync -a -I $PREFIX/lib/python$PY_VER/site-packages/ $BUILD_PREFIX/lib/python$PY_VER/site-packages/
    rm -rf $PREFIX/lib/python$PY_VER/site-packages
    rm -rf $BUILD_PREFIX/venv/lib/python3.6/site-packages
    ln -s $BUILD_PREFIX/lib/python$PY_VER/site-packages $BUILD_PREFIX/venv/lib/python$PY_VER/site-packages
    export PYTHONPATH=$BUILD_PREFIX/venv/lib/python$PY_VER/site-packages
    sed -i.bak "s@$BUILD_PREFIX/venv/lib@$BUILD_PREFIX/venv/lib', '$BUILD_PREFIX/venv/lib/python$PY_VER/site-packages@g" $PYTHON
  fi
fi

# Use the G77 ABI wrapper everywhere so that the underlying blas implementation
# can have a G77 ABI (currently only MKL)
export SCIPY_USE_G77_ABI_WRAPPER=1

if [[ "$python_impl" == "pypy" && "$target_platform" == "linux-ppc64le" ]]; then
    $PYTHON setup.py install --single-version-externally-managed --record=record.txt
else
    $PYTHON -m pip install . -vv
fi

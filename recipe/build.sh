#!/bin/bash


# Use OpenBLAS with 1 thread only as it seems to be using too many
# on the CIs apparently.
export OPENBLAS_NUM_THREADS=1


export LIBRARY_PATH="${PREFIX}/lib"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"

# Depending on our platform, shared libraries end with either .so or .dylib
if [[ `uname` == 'Darwin' ]]; then
    # Also, included a workaround so that `-stdlib=c++` doesn't go to
    # `gfortran` and cause problems.
    #
    # https://github.com/conda-forge/toolchain-feedstock/pull/8
    export CFLAGS="${CFLAGS} -stdlib=libc++ -lc++"
    export LDFLAGS="-headerpad_max_install_names -undefined dynamic_lookup -bundle -Wl,-search_paths_first -lc++"
else
    unset LDFLAGS
fi

# If OpenBLAS is being used, we should be able to find the libraries.
# As OpenBLAS now will have all symbols that BLAS or LAPACK have,
# create libraries with the standard names that are linked back to
# OpenBLAS. This will make it easy for NumPy to find it.
test -f "${PREFIX}/lib/libopenblas.a" && ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/libblas.a"
test -f "${PREFIX}/lib/libopenblas.a" && ln -fs "${PREFIX}/lib/libopenblas.a" "${PREFIX}/lib/liblapack.a"
test -f "${PREFIX}/lib/libopenblas${SHLIB_EXT}" && ln -fs "${PREFIX}/lib/libopenblas${SHLIB_EXT}" "${PREFIX}/lib/libblas${SHLIB_EXT}"
test -f "${PREFIX}/lib/libopenblas${SHLIB_EXT}" && ln -fs "${PREFIX}/lib/libopenblas${SHLIB_EXT}" "${PREFIX}/lib/liblapack${SHLIB_EXT}"

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# Need to clean these up as we don't want them as part of the NumPy package.
# If these are part of a BLAS (e.g. ATLAS), this won't cause us any problems
# as those would have been existing packages and `conda-build` would have
# ignored packaging those files anyways.
rm -f "${PREFIX}/lib/libblas.a"
rm -f "${PREFIX}/lib/liblapack.a"
rm -f "${PREFIX}/lib/libblas${SHLIB_EXT}"
rm -f "${PREFIX}/lib/liblapack${SHLIB_EXT}"

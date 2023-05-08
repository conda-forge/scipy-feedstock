#!/bin/bash
set -ex

# for reason see source section in meta.yaml
cd base

# Set a few environment variables that are not set due to
# https://github.com/conda/conda-build/issues/3993
export PIP_NO_BUILD_ISOLATION=True
export PIP_NO_DEPENDENCIES=True
export PIP_IGNORE_INSTALLED=True
export PIP_NO_INDEX=True
export PYTHONDONTWRITEBYTECODE=True

# need to use force to reinstall the tests the second time
# (otherwise pip thinks the package is installed already)
pip install dist/scipy*.whl --force-reinstall

# delete tests from baseline output "scipy"
if [[ "$PKG_NAME" == "scipy" ]]; then
    # verify $RECIPE_DIR/test_folders_to_delete.txt is up to date;
    # it's enough to do this on one platform
    if [[ "${target_platform}" == "linux-64" ]]; then
        # validating this is important because windows does not have
        # a good dynamic command like 'find ... -name tests -type d',
        # and we're using this file to do the deletions on windows.
        find ${SP_DIR}/scipy -name tests -type d -printf '%p\n' \
            | sort -k1 | sed "s:${SP_DIR}/scipy/::g" > testfolders
        echo "Test folders to be deleted:"
        cat testfolders
        # diff returns error code if there are differences
        diff $RECIPE_DIR/test_folders_to_delete.txt testfolders
    fi

    # do the actual deletion
    find ${SP_DIR}/scipy -name tests -type d | xargs rm -r

    # copy "test" with informative error message into installation
    cp $RECIPE_DIR/test_conda_forge_packaging.py $SP_DIR/scipy/_lib
fi

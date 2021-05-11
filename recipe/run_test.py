import sys
import os
import platform

import scipy

is_pypy = (platform.python_implementation() == "PyPy")
is_ppc64le = (platform.machine() == "ppc64le")

# for signature of scipy.test see here:
# https://github.com/scipy/scipy/blob/v1.6.3/scipy/_lib/_testutils.py#L27
kwargs = {"verbose": 2, "extra_argv": [f"-n{os.environ['CPU_COUNT']}"]}

if os.getenv("CI") == "drone":
    # Run only linalg, fft tests on drone as it times out
    kwargs['tests'] = ["scipy.linalg", "scipy.fft"]

sys.exit(not scipy.test(**kwargs))

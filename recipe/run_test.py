import sys
import os
import platform

import scipy

is_pypy = (platform.python_implementation() == "PyPy")
is_ppc64le = (platform.machine() == "ppc64le")

# for signature of scipy.test see here:
# https://github.com/scipy/scipy/blob/v1.6.3/scipy/_lib/_testutils.py#L27
kwargs = {"verbose": 1, "extra_argv": []}

if os.getenv("CI") == "travis" and is_pypy:
    kwargs["extra_argv"].append("-n4")
else:
    kwargs["extra_argv"].append(f"-n{os.environ['CPU_COUNT']}")

if (os.getenv("CI") == "drone") or ((os.getenv("CI") == "travis") and is_pypy):
    # Run only linalg, fft tests on drone as it timeouts, same for travis + pypy
    kwargs['tests'] = ["scipy.linalg", "scipy.fft"]

if os.getenv("CI") != "travis":
    kwargs['verbose'] = 2

sys.exit(not scipy.test(**kwargs))

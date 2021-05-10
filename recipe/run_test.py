import sys
import os
import platform

import scipy

is_pypy = (platform.python_implementation() == "PyPy")
is_ppc64le = (platform.machine() == "ppc64le")

# for signature of scipy.test see here:
# https://github.com/scipy/scipy/blob/v1.6.3/scipy/_lib/_testutils.py#L27
kwargs = {"verbose": 1, "extra_argv": []}

if os.getenv("CI") != "travis":
    kwargs["extra_argv"].append(f"-n{os.environ['CPU_COUNT']}")
elif is_pypy:
    kwargs["extra_argv"].append("-n4")

if os.getenv("CI") == "drone":
    # Run only linalg tests on drone as drone timeouts
    kwargs['tests'] = ["scipy.linalg", "scipy.fft"]

if os.getenv("CI") == "travis" and is_pypy:
    # Run only linalg, fft tests on travis with pypy as it timeouts
    kwargs['tests'] = ["scipy.linalg", "scipy.fft"]

if os.getenv("CI") != "travis":
    kwargs['verbose'] = 2

print(f"Running scipy test suite with kwargs: {kwargs}")
sys.exit(not scipy.test(**kwargs))

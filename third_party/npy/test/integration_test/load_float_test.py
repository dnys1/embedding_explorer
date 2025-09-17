import numpy as np
import sys

loaded = np.load(sys.argv[1])
expected = np.array([0.111, 2.22, -33.3], dtype=np.float32)

if not np.array_equal(loaded, expected):
    sys.stderr.write(f"Error: Expected [0.111, 2.22, -33.3], got {loaded}\n")
    exit(1)

if np.isfortran(loaded):
    sys.stderr.write(f"Error: Expected isfortran False, got {np.isfortran(loaded)}\n")
    exit(1)

if loaded.shape != (3,):
    sys.stderr.write(f"Error: Expected shape (3,), got {loaded.shape}\n")
    exit(1)

if loaded.dtype != "float32":
    sys.stderr.write(f"Error: Expected dtype float32, got {loaded.dtype}\n")
    exit(1)

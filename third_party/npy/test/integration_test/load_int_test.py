import numpy as np
import sys

loaded = np.load(sys.argv[1])

if loaded.tolist() != [[[1, 2, 3], [-4, 5, 6]], [[-32768, 0, 9], [10, 11, 32767]]]:
    sys.stderr.write(
        f"Error: Expected [[[1, 2, 3], [-4, 5, 6]], [[-32768, 0, 9], [10, 11, 32767]]], got {loaded}\n"
    )
    exit(1)

if np.isfortran(loaded):
    sys.stderr.write(f"Error: Expected isfortran False, got {np.isfortran(loaded)}\n")
    exit(1)

if loaded.shape != (2, 2, 3):
    sys.stderr.write(f"Error: Expected shape (2, 2, 3), got {loaded.shape}\n")
    exit(1)

if loaded.dtype != "int16":
    sys.stderr.write(f"Error: Expected dtype int16, got {loaded.dtype}\n")
    exit(1)

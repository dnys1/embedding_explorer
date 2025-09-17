import numpy as np
import sys

loaded = np.load(sys.argv[1])

if loaded.tolist() != [[True, True, True], [False, False, False]]:
    sys.stderr.write(
        f"Error: Expected [[True, True, True], [False, False, False]], got {loaded}\n"
    )
    exit(1)

if not np.isfortran(loaded):
    sys.stderr.write(f"Error: Expected isfortran True, got {np.isfortran(loaded)}\n")
    exit(1)

if loaded.shape != (2, 3):
    sys.stderr.write(f"Error: Expected shape (2, 3), got {loaded.shape}\n")
    exit(1)

if loaded.dtype != "bool":
    sys.stderr.write(f"Error: Expected dtype bool, got {loaded.dtype}\n")
    exit(1)

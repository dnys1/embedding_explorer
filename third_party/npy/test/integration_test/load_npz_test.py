import numpy as np
import sys

npzFile = np.load(sys.argv[1])
arr_0 = npzFile["arr_0.npy"]
arr_1 = npzFile["arr_1.npy"]

if arr_0.tolist() != [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]:
    sys.stderr.write(
        f"Error: Expected [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]], got {arr_0}\n"
    )
    exit(1)

if arr_1.tolist() != [2, 4, -8]:
    sys.stderr.write(f"Error: Expected [2, 4, -8], got {arr_1}\n")
    exit(1)

if not np.isfortran(arr_0):
    sys.stderr.write(f"Error: Expected isfortran True, got {np.isfortran(arr_0)}\n")
    exit(1)

if np.isfortran(arr_1):
    sys.stderr.write(f"Error: Expected isfortran False, got {np.isfortran(arr_1)}\n")
    exit(1)

if arr_0.shape != (2, 3):
    sys.stderr.write(f"Error: Expected shape (2, 3), got {arr_0.shape}\n")
    exit(1)

if arr_1.shape != (3,):
    sys.stderr.write(f"Error: Expected shape (3,), got {arr_1.shape}\n")
    exit(1)

if arr_0.dtype != ">f8":
    sys.stderr.write(f"Error: Expected dtype >f8, got {arr_0.dtype}\n")
    exit(1)

if arr_1.dtype != "<i2":
    sys.stderr.write(f"Error: Expected dtype <i2, got {arr_1.dtype}\n")
    exit(1)

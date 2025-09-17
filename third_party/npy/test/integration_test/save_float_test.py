import numpy as np
import sys

ndarray = np.array(
    [
        [-9.999, -1.1],
        [-0.12345, 0.12],
        [9.1, 1.999],
        [1.23, -1.2],
    ],
    dtype=">f8",
)
np.save(sys.argv[1], ndarray)

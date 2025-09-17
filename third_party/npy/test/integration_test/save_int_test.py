import numpy as np
import sys

ndarray = np.array(
    [[-9223372036854775808, -1], [0, 0], [1, 9223372036854775807]],
    dtype=">i8",
    order="F",
)
np.save(sys.argv[1], ndarray)

import numpy as np
import sys

ndarray = np.array([0, 1, 254, 255], dtype="|u1")
np.save(sys.argv[1], ndarray)

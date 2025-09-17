import numpy as np
import sys

arr_0 = np.array([[-1.0, -2.0], [0.1, 0.2]])
arr_1 = np.array([[0], [1], [-128], [127]], dtype="|i1")
np.savez_compressed(sys.argv[1], arr_0, arr_1)

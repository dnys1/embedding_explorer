import numpy as np
import sys

np.save(
    sys.argv[1],
    [
        [[True, True, True], [False, False, False]],
        [[False, False, False], [True, True, True]],
    ],
)

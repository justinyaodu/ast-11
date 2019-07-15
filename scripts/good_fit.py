import sys
import re
import numpy as np

# decides whether an ISOFIT table is good or bad

# reads the table from standard input
# INDEFs must be removed first
def is_good():
    # load array of stop codes
    row_nums, stop_codes = np.loadtxt(sys.stdin, unpack=True)

    # return whether number of 4's in array is less than some percentage
    return (stop_codes == 4).sum() / stop_codes.size < 0.3

if (is_good()): sys.exit(0)
else          : sys.exit(1)

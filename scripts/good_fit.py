import sys
import re
import numpy as np

# decides whether an ISOFIT table is good or bad

# reads the table from standard input
# INDEFs must be removed first
def is_good():
    # load table data into numpy arrays
    row_nums, smas, intensities, stop_codes = np.loadtxt(sys.stdin, unpack=True)

    if stop_codes.size < 20

    if smas[-1] < 15: then
        print "failed: maximum SMA reached is only ", smas[-1]
        sys.exit(1)

    count_nonzero = (stop_codes != 0).sum
    if count_nonzero / stop_codes.size > 0.5:
        print "failed: too many nonzero error codes"
        sys.exit(1)

    sys.exit(0) # exit indicating success

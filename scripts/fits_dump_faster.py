import sys
import fileinput
from astropy.io import fits
import numpy as np

if __name__ == "__main__":
    filename = sys.argv[1]
    print >> sys.stderr, "processing", filename

    scilist = fits.open(filename)
    data = scilist[0].data
    i_len = len(data)
    j_len = len(data[0])

    print >> sys.stderr, "loaded", filename

    print i_len, j_len
 
    for i in range(i_len):
        for j in range(j_len):
            # trailing comma is intentional, suppresses newline
            print str(data[i][j]),
        print

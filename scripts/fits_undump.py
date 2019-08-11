import sys
import fileinput
from astropy.io import fits
import numpy as np

if __name__ == "__main__":
    filename = sys.argv[1]
    data = np.loadtxt(sys.stdin)
    print >> sys.stderr, "data parsed"
    hdu = fits.PrimaryHDU(data)
    hdu.writeto(sys.argv[1])
    print >> sys.stderr, "FITS written"

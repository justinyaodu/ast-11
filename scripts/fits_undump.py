import sys
import fileinput
from astropy.io import fits
import numpy as np

if __name__ == "__main__":
    data = np.loadtxt(sys.stdin)
    hdu = fits.PrimaryHDU(data)
    hdu.writeto(sys.argv[1])

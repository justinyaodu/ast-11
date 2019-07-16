import sys
import re
import numpy as np
import fits_center
import math
from astropy.io import fits

# check to see if masking is excessive
def check_masking(mask_filename):
    mask_fits = fits.open(mask_filename)
    data = mask_fits[0].data
    
    row_num, x0, y0, ell, pa, sma = np.loadtxt(sys.stdin, unpack=True)

    # check for the INDEF replaced value of -10000 and replace with reasonable values
    center_x, center_y = fits_center.fits_center(mask_fits)
    x0[x0 == -10000] = center_x
    y0[y0 == -10000] = center_y
    ell[ell == -10000] = 0
    pa[pa == -10000] = 0

    # using the isophotes to get the percentage of masked/total
    # i is the index to go through each array value
    # count_in_ellipse is to count the number of pixels being tested
    # count_masked is to count how many pixels in ellipse are masked
    # count_good_isophotes is to count how many of the isophotes pass the test (if enough don't pass, then the mask = bad)
    count_good_isophotes = 0
    width, height = fits_center.fits_size(mask_fits)
    for i in range(len(x0)):
        count_in_ellipse = 0
        count_masked     = 0

        min_x = max(0, int(x0[i] - sma[i] - 2))
        max_x = min(width, int(x0[i] + sma[i] + 2))

        min_y = max(0, int(y0[i] - sma[i] - 2))
        max_y = min(width, int(y0[i] + sma[i] + 2))

        # limit the number of pixels which are checked
        for x in range(min_x, max_x):
            for y in range(min_y, max_y):
                if point_in_ellipse(x0[i], y0[i], ell[i], pa[i], sma[i], x, y):
                    count_in_ellipse += 1
                    if data[y, x] != 0:
                        count_masked += 1
        print "isophote " + str(i) + ": " + str(count_masked) + " of " + str(count_in_ellipse) + " masked"

        # skip this isophote if there are no pixels in it
        if count_in_ellipse == 0:
            continue
        
        # determine if fraction of masked pixels is satisfactory
        if count_masked / count_in_ellipse <= 0.4:
            print "  good isophote"
            count_good_isophotes += 1
    
    # determine if fraction of good isophotes is satisfactory
    if count_good_isophotes / len(x0) > 0.7:
        sys.exit(0)
    else:
        sys.exit(1)
                  
# test to see if the tested point is in the isophote ellipse                   
def point_in_ellipse(x0, y0, ell, pa, smaj, x, y):

    # prevent division by zero
    if (smaj == 0):
        return x == x0 and y == y0

    # calculate semi-minor axis length
    smin = smaj * (1 - ell)

    # translate everything so that ellipse is centered at the origin
    x -= x0
    y -= y0

    # convert position angle to rotation CCW from x-axis
    angle = 90 + pa

    # check whether point is in rotated ellipse

    return (math.pow(x * math.cos(angle) + y * math.sin(angle), 2) / math.pow(smaj, 2)
          + math.pow(x * math.sin(angle) - y * math.cos(angle), 2) / math.pow(smin, 2)) < 1

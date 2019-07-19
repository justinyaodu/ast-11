from __future__ import division
import sys
import re
import numpy as np
import fits_center
import math
from astropy.io import fits

class Ellipse:
    def __init__(self, x0, y0, ell, pa, sma):
        self.x0 = x0
        self.y0 = y0
        self.sin_angle = math.sin(pa + 90)
        self.cos_angle = math.cos(pa + 90)
        self.smaj_squared = math.pow(sma, 2)
        self.smin_squared = math.pow(sma * (1 - ell), 2)

    def contains_point(self, x, y):
        # prevent division by zero
        if (self.smaj_squared == 0):
            return x == self.x0 and y == self.y0

        # translate test point so that we can pretend the ellipse is centered at the origin
        x -= self.x0
        y -= self.y0

        # check whether point is in rotated ellipse

        return (math.pow(x * self.cos_angle + y * self.sin_angle, 2) / self.smaj_squared
              + math.pow(x * self.sin_angle - y * self.cos_angle, 2) / self.smin_squared) < 1

def check_masking(mask_filename):
    # count_in_ellipse is to count the number of pixels being tested
    # count_masked is to count how many pixels in ellipse are masked
    # count_good_isophotes is to count how many of the isophotes pass the test (if enough don't pass, then the mask = bad)
    count_in_ellipse     = 0
    count_masked         = 0
    count_isophotes      = 0
    count_good_isophotes = 0

    # load image data and dimensions 
    mask_fits = fits.open(mask_filename)
    data = mask_fits[0].data
    width, height = fits_center.fits_size(mask_fits)
    center_x, center_y = fits_center.fits_center(mask_fits)

    # load table data from stdin
    row_num, x0, y0, ell, pa, sma = np.loadtxt(sys.stdin, unpack=True)

    # check for the INDEF replaced value of -10000 and replace with reasonable values
    x0[x0 == -10000] = center_x
    y0[y0 == -10000] = center_y
    ell[ell == -10000] = 0
    pa[pa == -10000] = 0

    # using the isophotes to get the percentage of masked/total
    # i is the index to go through each array value
    # don't analyze the largest isophotes, because overmasking typically isn't
    # a problem further out, and this program gets a lot slower with large isophotes
    # don't check the smallest ones either
    for i in range(int(len(x0) * 2 / 5), int(len(x0) * 4 / 5)):
        
        isophote = Ellipse(x0[i], y0[i], ell[i], pa[i], sma[i])

        # create the bounding box; isophote is guaranteed to not exceed this
        min_x = max(0, int(x0[i] - sma[i] - 2))
        max_x = min(width, int(x0[i] + sma[i] + 2))
        min_y = max(0, int(y0[i] - sma[i] - 2))
        max_y = min(height, int(y0[i] + sma[i] + 2))
        
        # check every pixel in bounding box
        for x in range(min_x, max_x):
            for y in range(min_y, max_y):
                if isophote.contains_point(x, y):
                    count_in_ellipse += 1
                    if data[y, x] != 0: count_masked += 1
        
        count_isophotes += 1

        print "isophote " + str(i) + ": ", count_masked, "of", count_in_ellipse, "pixels masked", "(" + "{0:.2f}".format(count_masked / count_in_ellipse * 100) + "%)"
        
        # determine if fraction of masked pixels is satisfactory
        if count_masked / count_in_ellipse <= 0.2:
            count_good_isophotes += 1

    # determine if fraction of good isophotes is satisfactory
    print str(count_good_isophotes) + " of " + str(count_isophotes) + " tested isophotes are good"
    if count_good_isophotes / count_isophotes >= 0.7:
        print "satisfactory"
        sys.exit(0)
    else:
        print "unsatisfactory"
        sys.exit(1)

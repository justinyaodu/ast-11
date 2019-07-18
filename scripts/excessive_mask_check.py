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

class MaskChecker:
    # get the neighboring points which are in bounds
    def neighbors(self, x, y):
        x_coords = []
        if x != 0: x_coords.append(x - 1)
        if x != self.width - 1: x_coords.append(x + 1)

        y_coords = []
        if y != 0: y_coords.append(y - 1)
        if y != self.height - 1: y_coords.append(y + 1)

        neighbors = []
        for neighbor_x in x_coords:
            for neighbor_y in y_coords:
                neighbors.append((neighbor_x, neighbor_y))
        return neighbors

    def process_pixel(self, x, y, iteration, isophote):
        # mark pixel as visited by this iteration
        self.visited[x, y] = iteration * (1 if isophote.contains_point(x, y) else -1)

        if isophote.contains_point(x, y):
            # increment total number of pixels visited
            self.count_in_ellipse += 1

            # increment masked count if pixel is masked
            if self.data[y, x] != 0: self.count_masked += 1
            
            # return true to continue flood fill
            return True
        return False


    # returns whether a pixel should be ignored for the rest of this iteration
    def should_skip(self, x, y, iteration):
        return self.visited[x, y] == -iteration or self.visited[x, y] > 0

    # return whether a pixel hasn't been found to be inside an isophote yet
    def is_outside(self, point):
        return self.visited[point[0], point[1]] <= 0

    def __init__(self, mask_filename):
        # count_in_ellipse is to count the number of pixels being tested
        # count_masked is to count how many pixels in ellipse are masked
        # count_good_isophotes is to count how many of the isophotes pass the test (if enough don't pass, then the mask = bad)
        self.count_in_ellipse     = 0
        self.count_masked         = 0
        self.count_isophotes      = 0
        self.count_good_isophotes = 0
       
        # load image data and dimensions 
        self.mask_fits = fits.open(mask_filename)
        self.data = self.mask_fits[0].data
        self.width, self.height = fits_center.fits_size(self.mask_fits)
        self.center_x, self.center_y = fits_center.fits_center(self.mask_fits)

        # value is zero if pixel has not been visited
        # value is -n if the pixel is outside the nth isophote
        # and is n if the pixel is inside the nth isophote
        self.visited = np.zeros((self.width, self.height))

        # load table data from stdin
        self.row_num, self.x0, self.y0, self.ell, self.pa, self.sma = np.loadtxt(sys.stdin, unpack=True)

        # check for the INDEF replaced value of -10000 and replace with reasonable values
        self.x0[self.x0 == -10000] = self.center_x
        self.y0[self.y0 == -10000] = self.center_y
        self.ell[self.ell == -10000] = 0
        self.pa[self.pa == -10000] = 0

        # points on perimeter, just outside the last checked isophote
        self.perimeter = set()

        # using the isophotes to get the percentage of masked/total
        # i is the index to go through each array value
        # don't analyze the largest isophotes, because overmasking typically isn't
        # a problem further out, and this program gets a lot slower with large isophotes
        # don't check the smallest ones either
        for i in range(int(len(self.x0) * 2 / 5), int(len(self.x0) * 4 / 5)):
            isophote = Ellipse(self.x0[i], self.y0[i], self.ell[i], self.pa[i], self.sma[i])

            # if no points in perimeter, check the entire bounding box of the isophote
            if len(self.perimeter) == 0:
                # create the bounding box; isophote is guaranteed to not exceed this
                min_x = max(0, int(self.x0[i] - self.sma[i] - 2))
                max_x = min(self.width, int(self.x0[i] + self.sma[i] + 2))
                min_y = max(0, int(self.y0[i] - self.sma[i] - 2))
                max_y = min(self.height, int(self.y0[i] + self.sma[i] + 2))
                
                # check every pixel in bounding box
                for x in range(min_x, max_x):
                    for y in range(min_y, max_y):
                        self.process_pixel(x, y, i, isophote)

                # find perimeter points
                for x in range(min_x, max_x):
                    for y in range(min_y, max_y):
                        # if this pixel is inside the current isophote
                        if self.visited[x, y] == i:
                            for neighbor in self.neighbors(x, y):
                                # if neighbor is outside the current isophote
                                if self.is_outside(neighbor): self.perimeter.add(neighbor)
            
            # otherwise, use flood fill from perimeter
            else:
                new_perimeter = set()
                go_farther = set()

                def flood_fill(x, y, depth):
                    # return if this pixel should be skipped
                    if self.should_skip(x, y, i):
                        return

                    # prevent stack overflow
                    if depth == 900:
                        go_farther.add((x, y))
                        return
                    
                    if self.process_pixel(x, y, i, isophote):
                        # flood fill neighbors
                        for neighbor in self.neighbors(x, y):
                            flood_fill(neighbor[0], neighbor[1], depth + 1)
                    else:
                        # add to perimeter
                        new_perimeter.add((x, y))

                # flood fill until all points visited
                go_farther = self.perimeter
                while len(go_farther) > 0:
                    processing = go_farther
                    go_farther = set()
                    for point in processing:
                        flood_fill(point[0], point[1], 0)

                # assign perimeter points for next iteration
                self.perimeter = new_perimeter
                    
            self.count_isophotes += 1

            print "isophote " + str(i) + ": ", self.count_masked, "of", self.count_in_ellipse, "pixels masked", "(" + "{0:.2f}".format(self.count_masked / self.count_in_ellipse * 100) + "%)"
            
            # determine if fraction of masked pixels is satisfactory
            if self.count_masked / self.count_in_ellipse <= 0.15:
                self.count_good_isophotes += 1
        
        # determine if fraction of good isophotes is satisfactory
        print str(self.count_good_isophotes) + " of " + str(self.count_isophotes) + " tested isophotes are good"
        if self.count_good_isophotes / self.count_isophotes >= 0.8:
            sys.exit(0)
        else:
            sys.exit(1)

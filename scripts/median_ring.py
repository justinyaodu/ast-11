import sys
import fileinput
from astropy.io import fits
import numpy as np

np.set_printoptions(threshold=sys.maxsize)

def outOfBounds(xcor, ycor, xlen, ylen):
    if (xcor >= xlen or ycor >= ylen or xcor < 0 or ycor < 0):
        return True
    return False

ring_x = np.array([0,4,7,8,7,4,0,-4,-7,-8,-7,-4])
ring_y = np.array([8,7,4,0,-4,-7,-8,-7,-4,0,4,7])
def getRingArray(data, center_x, center_y, xlen, ylen):
    x_coords = ring_x + center_x
    y_coords = ring_y + center_y
    arr = []
    for i in range(len(ring_x)):
        x = x_coords[i]
        y = y_coords[i]
        if not outOfBounds(x, y, xlen, ylen):
            arr.append(data[x][y])
    return arr

if __name__ == "__main__":
    for line in sys.stdin:
        split = line.rstrip().split(':')
        filename = split[0]
        process_radius = int(split[1])
        print "processing", filename

        scilist = fits.open(filename)
        data = scilist[0].data
        xlen = len(data)
        ylen = len(data[0])
        newdata = np.copy(data)

        center_x = xlen / 2
        center_y = ylen / 2
        process_radius_squared = process_radius * process_radius
        
        for i in range(max(0, center_x - process_radius), min(xlen, center_x + process_radius)):
            for j in range(max(0, center_y - process_radius), min(ylen, center_y + process_radius)):
                if (i - center_x) * (i - center_x) + 
                   (j - center_y) * (j - center_y) >
                   process_radius_squared: continue
                arr = getRingArray(data, i, j, xlen, ylen)
                newdata[i][j] -= np.median(arr)

        hdu = fits.PrimaryHDU(newdata)

        # trims .fits extension from filename before appending
        newfilename = filename[:-5] + '_mediansub.fits'
        hdu.writeto(newfilename)
        print "processed", filename

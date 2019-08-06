import sys
import fileinput
from astropy.io import fits
import numpy as np

np.set_printoptions(threshold=sys.maxsize)

def outOfBounds(xcor, ycor, xlen, ylen):
    return xcor >= xlen or ycor >= ylen or xcor < 0 or ycor < 0

a = [1, 2, 3, 4, 5, 6, 7, 8, 8, 9, 9, 10, 10, 10]

b = list(a)
b.reverse()

ring_x = np.array(a + [-i for i in a] + a + [-i for i in a] + [10, 0, -10, 0])
ring_y = np.array(b + [-i for i in b] + [-i for i in b] + b + [0, 10, 0, -10])

print ring_x, ring_y
sys.exit(0)

ring_x = np.array([0, 4, 7, 8, 7, 4, 0, -4, -7, -8, -7, -4])
ring_y = np.array([8, 7, 4, 0, -4, -7, -8, -7, -4, 0, 4, 7])

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
    filename = sys.argv[1]
    print "processing", filename

    scilist = fits.open(filename)
    data = scilist[0].data
    xlen = len(data)
    ylen = len(data[0])
    newdata = np.copy(data)
    
    for i in range(xlen):
        print "    column", str(i + 1), "of", xlen
        for j in range(ylen):
            arr = getRingArray(data, i, j, xlen, ylen)
            newdata[i][j] -= np.median(arr)

    hdu = fits.PrimaryHDU(newdata)

    # trims .fits extension from filename before appending
    newfilename = filename[:-5] + '_modsub4.fits'
    hdu.writeto(newfilename)
    print "output to", newfilename

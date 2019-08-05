import sys
from astropy.io import fits
import numpy as np
np.set_printoptions(threshold=sys.maxsize)

def outOfBounds(xcor, ycor, xlen, ylen):
    if (xcor >= xlen or ycor >= ylen or xcor < 0 or ycor < 0):
        return True
    return False

def getRingArray(data, x, y, rad, xlen, ylen):
    arr = []
    for i in range(2*rad+1):
        xcor = i + x - rad
        ycor = y + rad
        if not outOfBounds(xcor, ycor, xlen, ylen):
            arr.append(data[xcor][ycor])
        ycor = y - rad
        if not outOfBounds(xcor, ycor, xlen, ylen):
            arr.append(data[xcor][ycor])
    for i in range(2*rad - 1):
        ycor = y - rad + 1 + i
        xcor = x - rad
        if not outOfBounds(xcor, ycor, xlen, ylen):
            arr.append(data[xcor][ycor])
        xcor = x + rad
        if not outOfBounds(xcor, ycor, xlen, ylen):
            arr.append(data[xcor][ycor])
    return arr

if __name__ == "__main__":
    if(not (len(sys.argv) == 2)):
        print("Usage: python MedianRing.py <input filename>")
    else:
        filename = sys.argv[1]
        scilist = fits.open(filename)
        data = scilist[0].data
        xlen = len(data)
        ylen = len(data[0])
        newdata = np.zeros((xlen,ylen))
        rad = 10
        for i in range(xlen):
            for j in range(ylen):
                arr = getRingArray(data, i, j, rad, xlen, ylen)
                subt = np.median(arr)
                newdata[i][j] = data[i][j] - subt
        hdu = fits.PrimaryHDU(newdata)

        # trims .fits extension from filename before appending
        newfilename = filename[:-5] + '_mediansub.fits'
        hdu.writeto(newfilename)

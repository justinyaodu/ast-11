import sys
from astropy.io import fits
import numpy as np
import multiprocessing
np.set_printoptions(threshold=np.nan)

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

def rmf(filename):
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
    newfilename = filename[:-5] + '_mediansub.fits'

    try:
        os.remove(newfilename)
    except OSError:
        pass

    hdu.writeto(newfilename)

def rmf_process(lines_to_run):
    for line in lines_to_run:
        try:
            filename = "VCC" + line + "_g.fits"
            rmf(filename)
            print("Completed RMF Procedure for " + str(filename))
        except Exception as e:
            print(e)
            continue

if __name__ == "__main__":
    if(not (len(sys.argv) == 2)):
        print("Usage: python MedianRing.py <tags filename>")
    else:
        tagsfile = sys.argv[1]
        f = open(tagsfile, "r")
        lines = []
        for line in f.readlines():
            lines.append(line[:-1])
        threads = 4
        splits = int(np.ceil(float(len(lines))/threads))
        linesplits = [lines[i:i + splits] for i in range(0, len(lines), splits)]
        processes = []
        for i in range(threads):
            p = multiprocessing.Process(target=rmf_process, args=(linesplits[i],))
            p.start()
            processes.append(p)
        for p in processes:
            p.join()
        print("All RMFs completed!")

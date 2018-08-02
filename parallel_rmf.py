import sys
from astropy.io import fits
import numpy as np
import multiprocessing
np.set_printoptions(threshold=np.nan)

def outOfBounds(xcor, ycor, xlen, ylen):
    return (xcor >= xlen or ycor >= ylen or xcor < 0 or ycor < 0)

def getRingArray(data, x, y, outer_rad, inner_rad, xlen, ylen):
    arr = []

    for i in range(2*outer_rad + 1):
        for j in range(outer_rad - inner_rad + 1):
            xcor = x - outer_rad + i
            y1 = y - outer_rad + j
            y2 = y + inner_rad + j
            if not outOfBounds(xcor,y1,xlen,ylen):
                arr.append(data[xcor][y1])
            if not outOfBounds(xcor,y2,xlen,ylen):
                arr.append(data[xcor][y2])

    for i in range(2*inner_rad - 1):
        for j in range(outer_rad - inner_rad + 1):
            ycor = y - inner_rad + 1 + i
            x1 = x - outer_rad + j
            x2 = x + outer_rad -j
            if not outOfBounds(x1,ycor,xlen,ylen):
                arr.append(data[x1][ycor])
            if not outOfBounds(x2,ycor,xlen,ylen):
                arr.append(data[x2][ycor])

    return arr

def rmf(filename,galname):
    file = open('gal_list.cat', "r")
    split = galname.split("_")
    gal = split[0]
    filt = split[1]
    parsedfil = []
    ind = -1
    for line in file:
        parsedfil.append(np.array(re.split("\s+", line)))
    parsedfile = np.array(parsedfil)
    target = filt + '_Re(arcsec)'
    for line in parsedfile:
        if(line[1] == 'Name'):
            for x in range(len(line)):
                if(line[x] == target):
                    ind = x
    rad = 0
    for line in parsedfile:
        if(line[1] == gal):
            rad = int(float(line[ind]))
    rad /= 0.187
    rad *= 5
    rad = int(rad)
    scilist = fits.open(filename)
    data = scilist[0].data
    x0 = int((scilist[0].header[3])/2)
    y0 = int((scilist[0].header[4])/2)
    xlen = len(data)
    ylen = len(data[0])
    newdata = np.zeros((xlen,ylen))
    outrad = 15
    inrad = 10
    for i in range(xlen):
        for j in range(ylen):
            if(i >= x0-rad and i <= x0+rad and j >= y0-rad and j <= y0+rad):
                arr = getRingArray(data, i, j, outrad, inrad, xlen, ylen)
                subt = np.median(arr)
                newdata[i][j] = data[i][j] - subt
            else:
                newdata[i][j] = data[i][j]
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
            galname = line + "_g"
            rmf(filename,galname)
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
        if len(linesplits) < threads:
            threads = len(linesplits)
        for i in range(threads):
            p = multiprocessing.Process(target=rmf_process, args=(linesplits[i],))
            p.start()
            processes.append(p)
        for p in processes:
            p.join()
        print("All RMFs completed!")

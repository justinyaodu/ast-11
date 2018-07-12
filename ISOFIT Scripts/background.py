import os
import pyraf
from pyraf import iraf

def getBgrd(tablename):
    iraf.tables()
    dumpfile = tablename + '_dump.txt'

    try:
        os.remove(dumpfile)
    except OSError:
        pass

    iraf.tdump(table=tablename,columns='INTENS',datafile=dumpfile)

    file = open(dumpfile,"r")
    lineList = file.readlines()
    lastLine = lineList[-1]
    lastLine = lastLine.replace('\t', '')
    lastLine = lastLine.replace('\s', '')
    lastLine = lastLine.replace('\n', '')
    bg = float(lastLine)
    file.close()

    os.remove(dumpfile)

    print bg

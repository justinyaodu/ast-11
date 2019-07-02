import os
import pyraf
from pyraf import iraf

# get background light value from model
def getBgrd(tablename):
    iraf.tables()
    dumpfile = tablename + '_dump.txt'

    try:
        os.remove(dumpfile)
    except OSError:
        pass

    # dumps light intensity data, from center outwards
    iraf.tdump(table=tablename,columns='INTENS',datafile=dumpfile)

    # uses outermost intensity value (last value) as background light intensity
    file = open(dumpfile,"r")
    lineList = file.readlines()
    lastLine = lineList[-1]
    lastLine = lastLine.replace('\t', '')
    lastLine = lastLine.replace('\s', '')
    lastLine = lastLine.replace('\n', '')
    bg = float(lastLine)
    file.close()

    os.remove(dumpfile)

    print(bg)

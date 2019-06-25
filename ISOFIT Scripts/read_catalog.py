import re
import numpy as np

#What does "PosAng" refer to?
#Which file are these for loops running through, and what do these files mean?
def getPosAng(galname, gallist):
    file = open(gallist, "r")
    split = galname.split("_")
    gal = split[0]
    filt = split[1]
    parsedfil = []
    u_ind = -1
    g_ind = -1
    i_ind = -1
    z_ind = -1
    for line in file:
        parsedfil.append(np.array(re.split("\s+", line)))
    parsedfile = np.array(parsedfil)
    for line in parsedfile:
        if(line[1] == 'Name'):
            for x in range(len(line)):
                if(line[x] == 'u_PA'):
                    u_ind = x
                    g_ind = x+1
                    i_ind = x+3
                    z_ind = x+4
    pa = 0
    for line in parsedfile:
        if(line[1] == gal):
            if(filt == "u"):
                pa = int(float(line[u_ind]))
            elif(filt == "g"):
                pa = int(float(line[g_ind]))
            elif(filt == "i"):
                pa = int(float(line[i_ind]))
            elif(filt == "z"):
                pa = int(float(line[z_ind]))
    if pa > 90:
        pa = 90
    if pa < -90:
        pa = -90
    print(pa)
    file.close()


def getSMA(galname, gallist):
    file = open(gallist, "r")
    split = galname.split("_")
    gal = split[0]
    filt = split[1]
    parsedfil = []
    u_ind = -1
    g_ind = -1
    i_ind = -1
    z_ind = -1
    for line in file:
        parsedfil.append(np.array(re.split("\s+", line)))
    parsedfile = np.array(parsedfil)
    for line in parsedfile:
        if(line[1] == 'Name'):
            for x in range(len(line)):
                if(line[x] == 'u_Re(arcsec)'):
                    u_ind = x
                    g_ind = x+1
                    i_ind = x+3
                    z_ind = x+4
    rad = 0
    for line in parsedfile:
        if(line[1] == gal):
            if(filt == "u"):
                rad = int(float(line[u_ind]))
            elif(filt == "g"):
                rad = int(float(line[g_ind]))
            elif(filt == "i"):
                rad= int(float(line[i_ind]))
            elif(filt == "z"):
                rad = int(float(line[z_ind]))
    rad /= 0.187
    rad *= 5
    print(rad)
    file.close()

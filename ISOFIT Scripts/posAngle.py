import re
import numpy as np

def getPosAng(galname, gallist):
    file = open(gallist, "r")
    split = galname.split("_")
    gal = split[0]
    filt = split[1]
    parsedfil = []
    for line in file:
        parsedfil.append(np.array(re.split("\s+", line)))
        #print(re.split("\s+", line))
    parsedfile = np.array(parsedfil)
    pa = 0
    for line in parsedfile:
        if(line[1] == gal):
            if(filt == "u"):
                pa = int(float(line[13]))
            elif(filt == "g"):
                pa = int(float(line[14]))
            elif(filt == "i"):
                pa = int(float(line[16]))
            elif(filt == "z"):
                pa = int(float(line[17]))
    print(pa)
    file.close()

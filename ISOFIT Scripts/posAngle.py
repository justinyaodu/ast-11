import re
import numpy as np

def getPosAng(gal, filt, filename):
    file = open(filename, "r")
    parsedfil = []
    for line in file:
        parsedfil.append(np.array(re.split("\s+", line)))
        #print(re.split("\s+", line))
    parsedfile = np.array(parsedfil)
    for line in parsedfile:
        if(line[1] == gal):
            if(filt == "u"):
                print(line[13])
            elif(filt == "g"):
                print(line[14])
            elif(filt == "i"):
                print(line[16])
            elif(filt == "z"):
                print(line[17])
            else:
                print("not found")
    file.close()

        
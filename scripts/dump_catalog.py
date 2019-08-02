import sys
import re
import numpy as np

# return the index offset needed to go from "u" to any filter
def get_offset(filter_name):
    if filter_name == "u": return 0
    if filter_name == "g": return 1
    if filter_name == "r": return 2
    if filter_name == "i": return 3
    if filter_name == "z": return 4
    raise ValueError("invalid filter")

# reads header row and gets indices for each attribute in the u filter
def get_indices(parsed_file):
    for line in parsed_file:
        if (line[1] == "Name"):
            for x in range(len(line)):
                if   line[x] == "u_PA"        : pa_index  = x
                elif line[x] == "u_Re(arcsec)": sma_index = x
                elif line[x] == "u_Ell"       : ell_index = x
                elif line[x] == "B_T(mag)"    : mag_index = x
            return pa_index, sma_index, ell_index, mag_index

# returns the ellipticity, position angle, and SMA in arcsec
if __name__ == "__main__":
    # read in file as numpy array
    file = open(sys.argv[1], "r")
    line_list = []
    for line in file:
        line_list.append(np.array(re.split("\s+", line)))
    parsed_file = np.array(line_list)

    # get indices for u filter
    pa_index, sma_index, ell_index, mag_index = get_indices(parsed_file)

    for filter_name in ["u", "g", "r", "i", "z"]:
        # get index offset for filter
        offset = get_offset(filter_name);

        output = open(filter_name + ".csv", "w+")
   
        for line in parsed_file:
            if line[0] == "#": continue

            galaxy = line[1]
            sma = line[sma_index + offset]
            mag = line[mag_index         ]

            if (sma == "-100.00" or mag == "-100.00"): continue
            output.write(galaxy + "," + mag + "," + str(float(sma) / 0.187) + "\n")

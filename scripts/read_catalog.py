import re
import numpy as np

# return the index offset needed to go from "u" to any filter
def get_offset(filter_name):
    if filter_name == "u": return 0
    if filter_name == "g": return 1
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
            return pa_index, sma_index, ell_index

# prints the ellipticity, position angle, initial SMA, min SMA, and max SMA
def get_properties(galaxy_and_filter, catalog, arcsec_to_px):
    # extract galaxy name and filter
    split = galaxy_and_filter.split("_")
    galaxy = split[0]
    filter_name = split[1]

    # read in file as numpy array
    file = open(catalog, "r")
    line_list = []
    for line in file:
        line_list.append(np.array(re.split("\s+", line)))
    parsed_file = np.array(line_list)

    # get indices for u filter
    pa_index, sma_index, ell_index = get_indices(parsed_file)

    # get index offset for filter
    offset = get_offset(filter_name);
    
    for line in parsed_file:
        if (line[1] == galaxy):
            pa  = float(line[pa_index  + offset])

            # conversion factor calculated from image in arcsec_to_px.py
            sma = float(line[sma_index + offset]) * arcsec_to_px

            ell = float(line[ell_index + offset])

            # semi-major axis length for ISOFIT to start at; default of 10 seems to work well
            sma_initial = 10

            # go all the way to the center
            sma_min = 0

            # safety factor is supposed to make sure the galaxy edges aren't clipped
            # even if the catalog values are off
            sma_max = sma * 2
            print ell, pa, sma_initial, sma_min, sma_max
            return

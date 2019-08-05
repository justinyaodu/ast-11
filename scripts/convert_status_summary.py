import sys
import re
import numpy as np

file = open(sys.argv[1], "r")
line_list = []
for line in file:
    line_list.append(np.array(re.split("\s+", line)))
parsed_file = np.array(line_list)

band_to_index = {"g":0, "i":1, "r":2, "u":3, "z":4}
index_to_band = ["g", "i", "r", "u", "z"]
status_to_text = ["failed", "successful modsub1", "successful modsub2", "successful assisted", "successful rmf", "no image"]

galaxies=dict()

for line in parsed_file:
    split = line[0].split("_")
    galaxy = split[0]
    band = split[1]
    
    if galaxy not in galaxies:
            galaxies[galaxy] = [5, 5, 5, 5, 5]

    galaxies[galaxy][band_to_index[band]] = int(line[1])

for galaxy in sorted(galaxies.keys()):
    for band_index in range(len(index_to_band)):
        band = index_to_band[band_index]
        status_text = status_to_text[galaxies[galaxy][band_index]]
        print galaxy + "_" + band + "," + status_text

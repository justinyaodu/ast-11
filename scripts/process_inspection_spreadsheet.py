import sys
import re
import numpy as np

file = sys.stdin
line_list = []
for line in file:
    # discard other lines (e.g. header)
    if line[:3] != "VCC": continue
    line_list.append(np.array(re.split(",", line.strip())))
parsed_file = np.array(line_list)

galaxies=dict()

for i in range(0, len(parsed_file), 5):
    gal_lines = parsed_file[i:i+5]

    split = gal_lines[0][0].split("_")
    galaxy = split[0]

    ref = ""
    for line in gal_lines:
        if line[2] == "ref":
            if ref != "":
                print >> sys.stderr, "multiple references specified for ", galaxy
                sys.exit(1)
            else:
                ref = line[0]

    for line in gal_lines:
        if line[4] == "redo":
            if ref == "":
                print >> sys.stderr, "no reference specified for ", galaxy
            else:
                action = "redo " + ref
        else:
            action = line[4]
            
        print line[0] + " " + action

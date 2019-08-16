import sys
import numpy as np
import csv

file = sys.stdin
line_list = []
for line in csv.reader(file, delimiter=','):
    # discard other lines (e.g. header)
    if line[0][:3] != "VCC": continue
    line_list.append(line)
parsed_file = np.array(line_list)

galaxies=dict()
errors=[]
actions=[]

for i in range(0, len(parsed_file), 5):
    gal_lines = parsed_file[i:i+5]

    split = gal_lines[0][0].split("_")
    galaxy = split[0]

    ref = ""
    for line in gal_lines:
        if line[2] == "ref":
            if ref != "":
                errors.append("multiple references specified for " + galaxy)
            else:
                ref = line[0]

    for line in gal_lines:
        if line[5] == "":
            errors.append("no action specified for " + galaxy)
            continue
        elif line[5] == "redo":
            if ref == "":
                errors.append("no reference specified for " + galaxy)
                continue
            else:
                action = "redo " + ref
        else:
            action = line[5]
            
        actions.append(line[0] + " " + line[3] + " " + action)

if (len(errors) == 0):
    print >> sys.stderr, "actions: " + str(len(actions))
    for action in actions: print action
else:
    for error in errors: print >> sys.stderr, "ERROR: " + error

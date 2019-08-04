import sys
import re
import numpy as np

file = open(sys.argv[1], "r")
line_list = []
for line in file:
    line_list.append(np.array(re.split("\s+", line)))
parsed_file = np.array(line_list)

count=dict()
count_failed=dict()

for line in parsed_file:
    # remove suffix from galaxy name
    galaxy = line[0][:7]

    # initialize counts to zero
    count[galaxy] = 0
    count_failed[galaxy] = 0

for line in parsed_file:
    galaxy = line[0][:7]
    count[galaxy] += 1
    if line[1] == "0": count_failed[galaxy] += 1

for galaxy in count:
    if count[galaxy] == count_failed[galaxy]: print galaxy

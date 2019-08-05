import sys
import re
import numpy as np

# some galaxies will fail the subtraction pipeline because the
# mask created from the flag image covers up too much of the galaxy
# when this happens, images of a galaxy in all bands will fail

# this script takes the output of ./foo.sh
# and outputs a list of all the galaxies that failed in all bands

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

total_failed = 0
for galaxy in count:
    if count[galaxy] == count_failed[galaxy]:
        print galaxy
        total_failed += count_failed[galaxy]

print >> sys.stderr, "total images failed from flag mask:", total_failed

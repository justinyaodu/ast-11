#!/bin/bash

# use imcopy to copy an image

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <table.tab>"

table="$1"

# abort if input file doesn't exist
assert_exists "$table"

# call Python script, giving a cleaned-up table print as input
./tprint.sh "$table" "STOP" | sed -e "s/INDEF/5/g" | python -c "import good_fit; good_fit.is_good()"

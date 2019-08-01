#!/bin/bash

# determine if an ISOFIT table has good fit data

# TODO here's a hack to disable this script
# without messing with anything else
exit 0
# TODO end hack

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <table.tab>"

table="$1"

# abort if input file doesn't exist
assert_exists "$table"

# call Python script, giving a cleaned-up table print as input
./tprint.sh "$table" "SMA,INTENS,STOP" | sed -e "s/INDEF/5/g" | python -c "import good_fit; good_fit.is_good()"

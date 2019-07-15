#!/bin/bash

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <table.tab>"

table="$1"

# abort if input file doesn't exist
assert_exists "$table"

# call the Python script
./tprint.sh "$table" "X0,Y0,ELLIP,PA,SMA" | sed -e "s/INDEF/-10000/g" | python -c "import excessive_mask_check; excessive_mask_check.METHOD_NAME()"
  

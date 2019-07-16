#!/bin/bash

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <table.tab> <mask.fits>"

table="$1"
mask_image="$2"

# abort if input file doesn't exist
assert_exists "$table" "$mask_image"

# call the Python script
./tprint.sh "$table" "X0,Y0,ELLIP,PA,SMA" | sed -e "s/INDEF/-10000/g" | python -c "import excessive_mask_check; excessive_mask_check.MaskChecker(\"$mask_image\")"
  

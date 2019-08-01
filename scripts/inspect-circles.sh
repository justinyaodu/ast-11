#!/bin/bash

# creates regions for a series of centered circles

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <image.fits>"

image="$1"

# abort if input file doesn't exist
assert_exists "$image"

# check xpa to make sure DS9 is running
if ! ds9_xpa_running; then abort "DS9 is not running"; fi

center="$(python -c "import fits_center; fits_center.get_fits_center(\"$image\")")"
x="$(grep -o '^[0-9]*' <<< "$center")"
y="$(grep -o '[0-9]*$' <<< "$center")"

for circle in "50 # color=red" "100 # color=orange" "150 # color=yellow" "200 # color=green" "250 # color=cyan" "300 # color=blue" "400 # color=pink" "500 # color=purple"; do
	xpaset -p ds9 regions command "\"circle $x $y $circle\""
done

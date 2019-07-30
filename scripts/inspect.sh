#!/bin/bash

# displays a FITS image in a running DS9 instance

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <modsub2_image.fits>"

image="$1"

# abort if input file doesn't exist
assert_exists "$image"

# check xpa to make sure DS9 is running
if ! ds9_xpa_running; then abort "DS9 is not running"; fi

xpaset -p ds9 fits "$image"
xpaset -p ds9 scale mode zscale

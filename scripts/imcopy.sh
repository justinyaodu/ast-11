#!/bin/bash

# use imcopy to copy an image

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <input_image.fits> <output_image.fits>"

input_image="$1"
output_image="$2"

# abort if input file doesn't exist
assert_exists "$input_image"

# if output file exists, also abort
assert_does_not_exist "$output_image"

# perform copy
./imcopy.cl "$input_image" "$output_image"

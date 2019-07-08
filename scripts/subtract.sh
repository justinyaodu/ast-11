#!/bin/bash

# use imarith to subtract one image from another

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 3 ] || abort "usage: $0 <image_file_1.fits> <image_file_2.fits> <output_image.fits>"

image_1="$1"
image_2="$2"
output_image="$3"

# abort if input files don't exist
assert_exists "$image_1" "$image_2"

# if output file exists, also abort
assert_does_not_exist "$output_image"

# perform subtraction
./subtract.cl "$image_1" "$image_2" "$output_image"

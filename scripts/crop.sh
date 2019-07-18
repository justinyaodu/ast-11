#!/bin/bash

# use imcopy to crop an image

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 4 ] || abort "usage: $0 <input_image.fits> <output_image.fits> <x crop> <y crop>"

input_image="$1"
output_image="$2"
x_crop="$3"
y_crop="$4"

# abort if input file doesn't exist
assert_exists "$input_image"

# if output file exists, also abort
assert_does_not_exist "$output_image"

# crop image
./crop.cl "$input_image" "$output_image" "$x_crop" "$y_crop"

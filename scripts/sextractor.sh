#!/bin/bash

# use Source Extractor to generate a pixel mask

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <input_image.fits> <output_mask.fits>"

input_image="$1"
output_mask="$2"

# abort if input file doesn't exist
assert_exists "$input_image"

# if output file exists, also abort
assert_does_not_exist "$output_mask"

# create mask
sextractor "$input_image" -DETECT_MINAREA 50 -DETECT_THRESH 3.0 -CHECKIMAGE_TYPE SEGMENTATION -CHECKIMAGE_NAME "$output_mask"

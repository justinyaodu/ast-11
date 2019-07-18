#!/bin/bash

# use Source Extractor to generate a pixel mask

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 3 ] || abort "usage: $0 <input_image.fits> <output_mask.fits> <threshold>"

input_image="$1"
output_mask="$2"
threshold="$3"

# the two lines below control where sextractor writes its catalog
# note that this is the catalog for the masking stage, not the catalog for GC detection
# since the catalog file is currently configured to print only the object number
# (because Source Extractor would refuse to run without any output columns specified),
# we can discard the catalog file output by writing it to /dev/null
catalog_file="/dev/null"
# catalog_file="$input_image.cat"

# abort if input file doesn't exist
assert_exists "$input_image"

# if output file exists, also abort
assert_does_not_exist "$output_mask"

# create mask
sextractor "$input_image" -DETECT_MINAREA 50 -DETECT_THRESH $threshold -CHECKIMAGE_TYPE SEGMENTATION -CHECKIMAGE_NAME "$output_mask" -CATALOG_NAME "$catalog_file"

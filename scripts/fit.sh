#!/bin/bash

# use ISOFIT/Ellipse to generate a galaxy light model

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 5 ] || abort "usage: $0 <input_image.fits> <output_table.tab> <harmonics> <object locator threshold>"

galaxy_and_filter="$1"
image_file="$2"
table_file="$3"
harmonics="$4"
ol_threshold="$5"

# abort if input file doesn't exist
assert_exists "$image_file"

# if output file exists, also abort
assert_does_not_exist "$table_file"

# generate parameter files
./generate-geompar.sh "$galaxy_and_filter" "$image_file"
./template-samplepar.sh "$harmonics"
./template-controlpar.sh "$ol_threshold"

# run ISOFIT or Ellipse, depending on configuration
if using_isofit; then
	./isofit.cl "$image_file" "$table_file"
else
	./ellipse.cl "$image_file" "$table_file"
fi

#!/bin/bash

# use Ellipse to generate a galaxy light model

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 4 ] || abort "usage: $0 <galaxyname_filter> <input_image.fits> <output_table.tab> <harmonics>"

galaxy_and_filter="$1"
image_file="$2"
table_file="$3"
harmonics="$4"

# abort if input file doesn't exist
assert_exists "$image_file"

# if output file exists, also abort
assert_does_not_exist "$table_file"

# generate geompar file
./generate-geompar.sh "$galaxy_and_filter" "$image_file"

# generate samplepar file
./template-samplepar.sh "$harmonics"

# run ISOFIT
./ellipse.cl "$image_file" "$table_file"

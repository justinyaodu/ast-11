#!/bin/bash

# use cmodel to generate an image from a galaxy light model

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <table.tab> <output_image.fits>"

table_file="$1"
output_image="$2"

# abort if input file doesn't exist
assert_exists "$table_file"

# if output file exists, also abort
assert_does_not_exist "$output_image"

# get background light value from table
background="$(./background.sh "$table_file")"

# perform copy
./cmodel.cl "$table_file" "$output_image" "$background"

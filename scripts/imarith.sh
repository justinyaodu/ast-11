#!/bin/bash

# use imarith to perform image operations

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 4 ] || abort "usage: $0 <image_file_1.fits> <operator> <image_file_2.fits> <output_image.fits>"

operand_1="$1"
operator="$2"
operand_2="$3"
output_image="$4"

# handle filenames with FITS indexing properly
image_1="$(sed -e 's/\[[0-9]\]$//g' <<< "$operand_1")"
image_2="$(sed -e 's/\[[0-9]\]$//g' <<< "$operand_2")"

# check to make sure each operand is either a number or a valid image file
grep -Pq '^[0-9.]+$' <<< "$operand_1" || assert_exists "$image_1"
grep -Pq '^[0-9.]+$' <<< "$operand_2" || assert_exists "$image_2"

# if output file exists, also abort
assert_does_not_exist "$output_image"

# perform subtraction
./imarith.cl "$operand_1" "$operator" "$operand_2" "$output_image"

#!/bin/bash

# use ISOFIT to generate a galaxy light model

source common.sh

# print usage message if number of parameters is incorrect
if [ "$#" -ne 4 ]; then
	>&2 echo "usage: $0 <galaxy-name_filter> <input_image.fits> <output_table.tab> <harmonics>"
	exit 1
fi

galaxy_and_filter="$1"
image_file="$2"
table_file="$3"
harmonics="$4"

# abort if input file doesn't exist
if [ ! -f "$image_file" ]; then
	>&2 echo "$0: error: input file does not exist"
	exit 1
fi

# if output file exists, also abort
if [ -f "$table_file" ]; then
	>&2 echo "$0: error: output file already exists"
	exit 1
fi

# generate geompar file
./generate-geompar.sh "$galaxy_and_filter" "$image_file"

# generate samplepar file
./template-samplepar.sh "$harmonics"

# run ISOFIT
./isofit.cl "$image_file" "$table_file"

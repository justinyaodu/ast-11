#!/bin/bash

# use Source Extractor to generate a pixel mask

source common.sh

# print usage message if number of parameters is incorrect
if [ "$#" -ne 2 ]; then
	>&2 echo "Usage: $0 <input_image.fits> <output_mask.fits>"
	exit 1
fi

infile="$1"
outfile="$2"

# abort if input file doesn't exist
if [ ! -f "$infile" ]; then
	>&2 echo "$0: error: input file does not exist"
	exit 1
fi

# if output file exists, also abort
if [ -f "$outfile" ]; then
	>&2 echo "$0: error: output file already exists"
	exit 1
fi

# create mask
sextractor "$infile" -DETECT_MINAREA 50 -DETECT_THRESH 3.0 -CHECKIMAGE_TYPE SEGMENTATION -CHECKIMAGE_NAME "$outfile"

#!/bin/bash

# use sextractor.sh and imcopy.sh to generate pixel mask files

source common.sh

# print usage message if number of parameters is incorrect
if [ "$#" -ne 1 ]; then
	>&2 echo "Usage: $0 <input.fits>"
	exit 1
fi

infile="$1"
outfile="${infile::-5}_seg.fits"
copyfile="$infile.pl"

# abort if input file doesn't exist
if [ ! -f "$infile" ]; then
	>&2 echo "$0: error: input file does not exist"
	exit 1
fi

# if either output file exists, also abort
if [ -f "$outfile" ] || [ -f "$copyfile" ]; then
	>&2 echo "$0: error: output file already exists"
	exit 1
fi

# create mask
./sextractor.sh "$infile" "$outfile"

# copy somegalaxy_seg.fits to somegalaxy.fits.pl
./imcopy.sh "$outfile" "$copyfile"

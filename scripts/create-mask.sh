#!/bin/bash

# use sextractor.sh and imcopy.sh to generate pixel mask files

usage() {
	>&2 echo "usage: $0 <input.fits> [--clean]"
}

# print usage message if number of parameters is incorrect
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
	usage
	exit 1
fi

infile="$1"

# assuming the input file ends with "_modsub1.fits"
# this removes those 13 characters
outfile="${infile::-13}_seg.fits"

copyfile="$infile.pl"
cleanopt="$2"

# if option specified
if [ "$cleanopt" != "" ]; then
	# if option is correctly specified, delete files
	if [ "$cleanopt" == "--clean" ]; then
		rm -f "$outfile" "$copyfile"
		exit 0
	# otherwise, print usage message
	else
		usage
		exit 1
	fi
fi

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

#!/bin/bash

# use imarith to subtract one image from another

# print usage message if number of parameters is incorrect
if [ "$#" -ne 3 ]; then
	>&2 echo "Usage: $0 <image_file_1.fits> <image_file_2.fits> <output_image.fits>"
	exit 1
fi

infile1="$1"
infile2="$2"
outfile="$3"

ulimit -s unlimited

# abort if input files don't exist
if [ ! -f "$infile1" ] || [ ! -f "$infile2" ]; then
	>&2 echo "$0: error: input file does not exist"
	exit 1
fi

# if output file exists, also abort
if [ -f "$outfile" ]; then
	>&2 echo "$0: error: output file already exists"
	exit 1
fi

# perform subtraction
./subtract.cl "$infile1" "$infile2" "$outfile" > /dev/null

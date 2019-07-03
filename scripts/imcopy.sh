#!/bin/bash

# use imarith to subtract one image from another

# print usage message if number of parameters is incorrect
if [ "$#" -ne 2 ]; then
	>&2 echo "Usage: $0 <input.fits> <output.fits>"
	exit 1
fi

infile="$1"
outfile="$2"

ulimit -s unlimited

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

# perform copy
./imcopy.cl "$infile" "$outfile" > /dev/null
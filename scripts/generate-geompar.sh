#!/bin/bash

# looks up appropriate initial values for geometric parameters using catalog data
# and generates reasonable min and max values

# print usage message if number of parameters is incorrect
if [ "$#" -ne 2 ]; then
	>&2 echo "Usage: $0 <galaxy-name> <geompar-filename.par>"
	exit 1
fi

galaxy="$1"
geomparfile="$2"

# if output file exists, abort
if [ -f "$geomparfile" ]; then
	>&2 echo "$0: error: output file already exists"
	exit 1
fi

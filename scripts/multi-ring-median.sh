#!/bin/bash

# runs ring-median.sh for each image in a directory containing multiple galaxy directories

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory/containing/galaxy/directories>"

containing_dir="$(strip_trailing_slash "$1")"

# loop over everything in directory
for galaxy_dir in "$containing_dir"/*; do
	
	# skip if not a directory
	[ -d "$galaxy_dir" ] || continue
		
	for file in "$galaxy_dir"/VCC????_?.fits; do

		# use presence of indicator file as a safe stop signal
		stop_if_requested

		print_banner "processing image file $file"

		./ring-median.sh "$file"
	done
done

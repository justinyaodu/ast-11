#!/bin/bash

# runs main.sh for each image in a directory containing multiple galaxy directories

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory/containing/galaxy/directories>"

containing_dir="$(strip_trailing_slash "$1")"

# loop over everything in directory
for galaxy_dir in "$containing_dir"/*; do

	# skip if not a directory
	[ -d "$galaxy_dir" ] || continue

	galaxy_name="$(basename "$galaxy_dir")"

	# filters in order of preference
	# TODO ask mentors about which are best, after g
	for filter in "g" "u" "i" "z" "r"; do
		file="$galaxy_dir/${galaxy_name}_${filter}.fits"
		
		# skip if no image exists for filter
		if [ ! -f "$file" ]; then continue; fi
		
		print_banner "processing image file $file"

		if ! ./main.sh "$file"; then
			# mark as failed
			touch "$file.failed"
		fi
	done
done

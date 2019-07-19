#!/bin/bash

# runs main.sh for each image in a directory containing multiple galaxy directories

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory/containing/galaxy/directories>"

# remove trailing slash on directory, if any
# makes no practical difference, but looks nicer when printing
containing_dir="$(sed -e 's/\/$//g' <<< "$1")"

# loop over everything in directory
for galaxy_dir in "$containing_dir"/*; do

	# skip if not a directory
	[ -d "$galaxy_dir" ] || continue

	# check every file in directory
	for file in "$galaxy_dir"/*; do

		# if this file is an original image file
		if grep -q 'VCC[0-9][0-9][0-9][0-9]_[ugriz]\.fits$' <<< "$(basename "$file")"; then

			# print a fancy banner
			echo
			echo "======== processing image file $file ========"
			echo

			# run main.sh on this image
			# if it's unsuccessful, create indicator file
			if ! ./main.sh "$file"; then
				touch "$file.failed"
			fi
		fi
	done
done

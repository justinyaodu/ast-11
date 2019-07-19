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

	# create output directory
	output_dir="$galaxy_dir/output"
	mkdir "$output_dir"

	# if "long" directory exists, use the image files in there
	if [ -d "$galaxy_dir/long" ]; then
		galaxy_dir="$galaxy_dir/long"
	fi

	for file in "$galaxy_dir"/*; do

		# if this file is an original image file
		if grep -q 'VCC[0-9][0-9][0-9][0-9]_[ugriz]\.fits' <<< "$file"; then

			# print a fancy banner
			echo
			echo "======== processing image file $file ========"
			echo

			# create a symlink to the image file in the output folder
			ln -s "$file" "$output_dir/$(basename "$file")"

			# run main.sh on this image
			echo ./main.sh "$file"
		fi
	done
done

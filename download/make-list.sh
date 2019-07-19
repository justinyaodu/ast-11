#!/bin/bash

# capture all output from this section of the script
{
	# loop over all galaxy directories
	for item in VCC????; do

		# skip item if it isn't a directory
		[ -d "$item" ] || continue

		# if long folder exists (e.g. "VCC0024/long"), use it,
		# otherwise use the parent folder (e.g. "VCC0024")
		if [ -d "$item/long" ]; then
			echo "$item/long"
		else
			echo "$item"
		fi
	done

# pipe output to next section of script
# each line is the folder that should be used for images from that galaxy
} | {
	# read each line into the variable image_dir
	while read -r image_dir; do
		# show the directory currently being processed,
		# so the user doesn't think the script is stuck
		# use >&2 to output to standard error,
		# which will appear on the console
		# (standard output is being redirected to a file)
		>&2 echo "processing dir $image_dir"

		# show all files in directory, with the timestamp as well
		# for each file, print an epoch timestamp and the filename
		stat --printf="%Y %n\n" "$image_dir"/*
	done
} > list.txt

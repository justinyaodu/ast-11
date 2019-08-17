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
		
	# use presence of indicator file as a safe stop signal
	stop_if_requested

	galaxy_name="$(basename "$galaxy_dir")"

	for filter in "g" "i" "r" "u" "z"; do

		file="$galaxy_dir/${galaxy_name}_${filter}.fits"
		
		# skip if no image exists for filter
		if [ ! -f "$file" ]; then continue; fi
		
		print_banner "processing image file $file"

		./main.sh "$file" 'true'
	done

	# rerun all images without flag image masking if they all fail
	if [ "$(cat "$galaxy_dir"/*.status | sort | uniq)" = '0' ]; then
		echo_debug "possible flag image masking failure: $galaxy_dir"
		if [ -f "$galaxy_dir/no-flag-mask" ]; then
			echo_debug "all images failed even after disabling flag image masking; skipping: $galaxy_dir"
		else
			touch "$galaxy_dir/no-flag-mask"

			for filter in "g" "i" "r" "u" "z"; do

				file="$galaxy_dir/${galaxy_name}_${filter}.fits"

				# skip if no image exists for filter
				if [ ! -f "$file" ]; then continue; fi
				
				# silently reset
				./reset.sh "$file" 2>&1 > /dev/null
				
				print_banner "reprocessing image file $file"

				./main.sh "$file" 'false'
			done
		fi
	fi
done

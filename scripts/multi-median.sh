#!/bin/bash

# runs median_ring.py for each galaxy image in a directory tree

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory>"

containing_dir="$(strip_trailing_slash "$1")"

# loop over everything in directory
for image in $(find "$containing_dir" | grep 'VCC...._[ugriz].fits$'); do

	modsub2_image="$(sed -e 's/\.fits$/_modsub2.fits/g' <<< "$image")"
	if [ -f "$modsub2_image" ]; then
		echo_debug "skipping image, has modsub2: $image"
		continue
	fi

	output_image="$(sed -e 's/\.fits$/_mediansub.fits/g' <<< "$image")"
	if [ -f "$output_image" ] && [ "$output_image" -nt "$image" ]; then
		echo_debug "skipping image, up to date: $image"
		continue
	fi

	# value after the colon is half the width of the box
	# to perform ring median subtraction on
	# processing the entire image would take significantly longer
	echo "$image:400"
# feed it to the median ring script
done | python median_ring.py

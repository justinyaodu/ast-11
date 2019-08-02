#!/bin/bash

# run the ring median filter on an image

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image.fits>"

image="$1"

assert_exists "$image"

output_image="$(sed -e 's/\.fits$/_modsub4.fits/g' <<< "$image")"
if [ -f "$output_image" ] && [ "$output_image" -nt "$image" ]; then
	debug_echo "final image $output_image up to date, skipping"
	exit 0
fi

python ring_median.py "$image"

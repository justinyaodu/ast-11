#!/bin/bash

# run the ring median filter on an image

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image.fits>"

original_image="$1"

assert_exists "$original_image"

output_image="$(sed -e 's/\.fits$/_rmf.fits/g' <<< "$original_image")"
if [ -f "$output_image" ] && [ "$output_image" -nt "$original_image" ]; then
	echo_debug "final image $output_image up to date, skipping"
	exit 0
fi

assert_successful python fits_dump.py "$original_image" | ./ring_median | python fits_undump.py "$output_image"

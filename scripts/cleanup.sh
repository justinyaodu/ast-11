#!/bin/bash

# cleanup intermediary files from subtraction pipeline to save disk space

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image.fits>"

original_image="$1"
directory="$(dirname "$original_image")"

galaxy_and_filter="$(get_galaxy_and_filter "$original_image")"

for suffix in "_mod1.fits" "_modsub1.fits" "_seg.fits" "_mod2.fits" "_mod3.fits"; do
	rm "$directory/$galaxy_and_filter$suffix"
done

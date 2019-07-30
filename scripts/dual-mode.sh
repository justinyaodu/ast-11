#!/bin/bash

# uses SExtractor dual mode to perform multi-band photometry on modsub2 images

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory/containing/modsub2/images>"

directory="$1"

galaxy_and_filter="$(get_galaxy_and_filter "$original_image")"

for suffix in "_mod1.fits" "_modsub1.fits" "_seg.fits" ".fits.pl" "_mod2.fits"; do
	rm "$directory/$galaxy_and_filter$suffix"
done

#!/bin/bash

# remove all files from subtraction pipeline, leaving only original files

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image>"

original_image="$1"
directory="$(dirname "$1")"

galaxy_and_filter="$(get_galaxy_and_filter "$original_image")"

for suffix in "_createmodel1.log" "_createmodel2.log" ".fits.pl" "_mask.log" "_mod1_fit.log" "_mod1.fits" "_mod1_model.log" "_mod1.reg" "_mod1.tab" "_mod2_fit.log" "_mod2.fits" "_mod2_model.log" "_mod2.reg" "_mod2.tab" "_modsub1.fits" "_modsub2.fits" "_seg.fits"; do
	rm "$directory/$galaxy_and_filter$suffix"
done

#!/bin/bash

# use sextractor-mask.sh and imcopy.sh to generate pixel mask files

source common.sh

usage_message="usage: $0 <input.fits> <model.tab>"

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "$usage_message"

input_image="$1"
model_table="$2"

[ ${input_image: -13} == "_modsub1.fits" ] || abort "error: image file name does not end with _modsub1.fits"

# assuming the input file ends with "_modsub1.fits"
# this removes those 13 characters
seg_image="${input_image::-13}_mask.fits"

# removes those same characters, but ends with .fits.pl instead
pixel_list="${input_image::-13}.fits.pl"

assert_exists "$input_image"
assert_does_not_exist "$seg_image"
remove_if_exists "$pixel_list"

threshold="2.0"
iterations="0"

# create mask
./sextractor-mask.sh "$input_image" "$seg_image" "$threshold"

# while image is overly masked, increase the threshold and try again
while ! ./excessive-mask-check.sh "$model_table" "$seg_image"; do

	# if iterated too many times, give up and continue with current mask
	(( iterations++ ))
	if [ "$iterations" -eq 10 ]; then
		echo_debug "too many remasking iterations, giving up and disabling masking"
		rm "$seg_image"
		exit 1
	fi

	# increase threshold
	threshold="$(bc -l <<< "$threshold + 0.5")"
	echo_debug "masking deemed too aggressive, increasing threshold to $threshold"

	# remove output file
	rm "$seg_image"

	# try masking again with increased threshold
	./sextractor-mask.sh "$input_image" "$seg_image" "$threshold"
done

# convert mask image to pixel list format
assert_successful ./imcopy.sh "$seg_image" "$pixel_list"

#!/bin/bash

# use sextractor.sh and imcopy.sh to generate pixel mask files

source common.sh

usage_message="usage: $0 <input.fits> <model.tab> [--clean]"

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || [ $# -eq 3 ] || abort "$usage_message"

input_image="$1"
model_table="$2"

[ ${input_image: -13} == "_modsub1.fits" ] || abort "error: image file name does not end with _modsub1.fits"

# assuming the input file ends with "_modsub1.fits"
# this removes those 13 characters
output_image="${input_image::-13}_seg.fits"

# removes those same characters, but ends with .fits.pl instead
copy_image="${input_image::-13}.fits.pl"

clean_option="$3"

# if option specified
if [ "$clean_option" != "" ]; then
	# if option is correctly specified, delete files
	if [ "$clean_option" == "--clean" ]; then
		rm -f "$output_image" "$copy_image"
		exit 0
	# otherwise, print usage message
	else
		abort "$usage_message"
	fi
fi

assert_exists "$input_image"
assert_does_not_exist "$output_image" "$copy_image"

threshold="1.5"

# create mask
./sextractor.sh "$input_image" "$output_image" "$threshold"

# while image is overly masked, increase the threshold and try again
while ! ./excessive-mask-check.sh "$model_table" "$output_image"; do
	rm "$output_image"
	threshold="$(bc -l <<< "$threshold + 0.5")"
	echo_debug "masking deemed too aggressive, increasing threshold to $threshold"
	./sextractor.sh "$input_image" "$output_image" "$threshold"
done

# copy somegalaxy_seg.fits to somegalaxy.fits.pl
./imcopy.sh "$output_image" "$copy_image"

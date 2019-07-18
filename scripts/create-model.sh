#!/bin/bash

# use fit.sh and model.sh to create a galaxy light model image

source common.sh

usage_message="usage: $0 <original_image.fits>"

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "$usage_message"

original_image="$1"
assert_exists "$original_image"

filename_stripped="$(strip_extension "$original_image")"

if [ -f "${filename_stripped}_mod1.tab" ]; then
	echo_debug "first pass model files already exist; creating second pass model"
	output_table="${filename_stripped}_mod2.tab"
else
	echo_debug "first pass model files do not exist; creating first pass model"
	output_table="${filename_stripped}_mod1.tab"
fi

assert_does_not_exist "$output_table"

# run ISOFIT/Ellipse
./fit.sh "$(get_galaxy_and_filter "$original_image")" "$original_image" "$output_table" "2 3 4" "1"

# create DS9 region file with isophote ellipses
./region-from-table.sh "$output_table"

# run bmodel/cmodel
./model.sh "$output_table"

#!/bin/bash

# use fit-pseudo.sh and model.sh to create a galaxy light model image

source common.sh

usage_message="usage: $0 <original_image.fits> <iteration number> <previous table>"

# print usage message if number of parameters is incorrect
[ $# -eq 3 ] || abort "$usage_message"

original_image="$1"
reference_table="$3"
assert_exists "$original_image" "$reference_table"

iteration="$2"

filename_stripped="$(strip_extension "$original_image")"

output_table="${filename_stripped}_mod$iteration.tab"
assert_does_not_exist "$output_table"

echo_debug "using previous table $reference_table"

assert_successful ./fit-pseudo.sh "$(get_galaxy_and_filter "$original_image")" "$original_image" "$output_table" "$reference_table"

# create DS9 region file with isophote ellipses (optional, but nice to have)
./region-from-table.sh "$output_table"

# run bmodel/cmodel
assert_successful ./model.sh "$output_table"

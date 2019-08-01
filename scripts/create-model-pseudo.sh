#!/bin/bash

# use fit-pseudo.sh and model.sh to create a galaxy light model image

source common.sh

usage_message="usage: $0 <original_image.fits> <iteration number>"

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "$usage_message"

original_image="$1"
assert_exists "$original_image"

iteration="$2"

filename_stripped="$(strip_extension "$original_image")"

output_table="${filename_stripped}_mod$iteration.tab"
assert_does_not_exist "$output_table"

for band in 'g' 'i' 'z' 'u' 'r'; do
	previous_table="$(sed -e "s/_.\.fits/_${band}_mod2.tab/g" <<< "$original_image")"
	[ -f "$previous_table" ] && break
done
[ -f "$previous_table" ] || abort "no previous table found"

echo_debug "using previous table $previous_table"

assert_successful ./fit-pseudo.sh "$(get_galaxy_and_filter "$original_image")" "$original_image" "$output_table" "$previous_table"

# create DS9 region file with isophote ellipses (optional, but nice to have)
./region-from-table.sh "$output_table"

# run bmodel/cmodel
assert_successful ./model.sh "$output_table"

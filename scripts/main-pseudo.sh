#!/bin/bash

# functionally similar to main.sh, but will attempt to use existing
# ISOFIT tables as input to overcome fitting failures

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <original_image.fits> <reference_galaxy_and_filter>"

original_image="$1"
reference="$2"

# abort if input file doesn't exist
assert_exists "$original_image"

# strip .fits extension, but retain galaxy name and directory information
# e.g. "/some/path/VCC1827_i.fits" becomes "/some/path/VCC1827_i"
name_base=${original_image::-5}

# check if final image already exists
modsub3="${name_base}_modsub3.fits"
if [ -f "$modsub3" ]; then
	echo_debug "modsub3 image already exists, skipping"
	exit 0
fi

# silently delete files if any exist
./reset-pseudo.sh "$original_image" > /dev/null 2>&1

# copy mask from reference image, if one exists
reference_mask="${name_base::-9}$reference.fits.pl"
if [ -f "$reference_mask" ]; then
	# backup old pixel mask
	mask="$name_base.fits.pl"
	if [ -f "$mask" ] && [ ! -f "$mask.old" ]; then
		mv "$mask" "$mask.old"
	else
		rm "$mask"
	fi

	cp "$reference_mask" "$mask"
fi

# use mod2 table if it exists, otherwise mod1 table, otherwise abort
reference_table="${name_base::-9}${reference}_mod2.tab"
[ -f "$reference_table" ] || reference_table="${name_base::-9}${reference}_mod1.tab"
assert_exists "$reference_table"

# generate light model
assert_successful run_and_log "${name_base}_createmodel3.log" ./create-model-pseudo.sh "$original_image" "3" "$reference_table"

# perform subtraction
assert_successful ./imarith.sh "$original_image" "-" "${name_base}_mod3.fits" "${name_base}_modsub3.fits"

echo "3" > "$original_image.status"

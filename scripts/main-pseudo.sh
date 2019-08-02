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

	# if original image has been updated since modsub3 was generated
	if [ "$original_image" -nt "$modsub3" ]; then

		echo_debug "final image is outdated; resetting and running again"

		# reset directory, so that we can run again
		./reset.sh "$original_image"
	else
		echo_debug "modsub3 image already exists and is up to date, skipping"
		exit 0
	fi
fi

# silently delete files if any exist
./reset-pseudo.sh "$original_image" > /dev/null 2>&1

# copy pixel mask
old_mask="$name_base.fits.pl"
[ -f "$old_mask" ] && [ ! -f "$old_mask.old" ] && mv "$old_mask" "$old_mask.old"
reference_mask="${name_base::-9}$reference.fits.pl"
cp "$reference_mask" "$old_mask"

reference_table="${name_base::-9}${reference}_mod2.tab"

# generate light model
assert_successful run_and_log "${name_base}_createmodel3.log" ./create-model-pseudo.sh "$original_image" "3" "$reference_table"

# perform subtraction
assert_successful ./subtract.sh "$original_image" "${name_base}_mod3.fits" "${name_base}_modsub3.fits"

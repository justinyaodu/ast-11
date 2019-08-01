#!/bin/bash

# functionally similar to main.sh, but will attempt to use existing
# ISOFIT tables as input to overcome fitting failures

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image.fits>"

original_image="$1"

# abort if input file doesn't exist
assert_exists "$original_image"

# strip .fits extension, but retain galaxy name and directory information
# e.g. "/some/path/VCC1827_i.fits" becomes "/some/path/VCC1827_i"
name_base=${original_image::-5}

# check if final image already exists
modsub2="${name_base}_modsub2.fits"
if [ -f "$modsub2" ]; then

	# if original image has been updated since modsub2 was generated
	if [ "$original_image" -nt "$modsub2" ]; then

		echo_debug "final image is outdated; resetting and running again"

		# reset directory, so that we can run again
		./reset.sh "$original_image"
	else
		echo_debug "modsub2 image already exists and is up to date, skipping"
		exit 0
	fi
elif [ -f "$original_image.failed" ] && ! ls "$(dirname "$original_image)" | grep -q 'mod2.tab$'; then
	abort "last run failed, and no tables in other bands; will not attempt rerun"
fi

# silently delete files if any exist
./reset.sh "$original_image" > /dev/null 2>&1

# use a regular expression to find the galaxy VCC name and the image filter
# TODO we might need to update this and other parts of the pipeline that assume VCC objects
# if we want to make the pipeline work for other objects
# alternatively, we could invent "fake" VCC numbers for those objects...
galaxy_and_filter="$(get_galaxy_and_filter "$original_image")"

# generate first pass light model
assert_successful run_and_log "${name_base}_createmodel1.log" ./create-model-pseudo.sh "$original_image" "1"

# perform subtraction
assert_successful ./subtract.sh "$original_image" "${name_base}_mod1.fits" "${name_base}_modsub1.fits"

# generate mask for remaining bright objects
assert_successful run_and_log "${name_base}_mask.log" ./create-mask.sh "${name_base}_modsub1.fits" "${name_base}_mod1.tab"

# generate second pass light model
assert_successful run_and_log "${name_base}_createmodel2.log" ./create-model-pseudo.sh "$original_image" "2"

# perform final subtraction
assert_successful ./subtract.sh "$original_image" "${name_base}_mod2.fits" "${name_base}_modsub2.fits"
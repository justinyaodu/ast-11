#!/bin/bash

# implements the complete workflow

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <original_image.fits> <flag image masking (true/false)>"

original_image="$1"

use_flag="$2"
case "$use_flag" in
true | false)
	# ok, do nothing
	;;
*)
	abort "not true or false: $use_flag"
	;;
esac

# abort if input file doesn't exist
assert_exists "$original_image"

# strip .fits extension, but retain galaxy name and directory information
# e.g. "/some/path/VCC1827_i.fits" becomes "/some/path/VCC1827_i"
name_base=${original_image::-5}

if [ -f "$original_image.status" ]; then
	echo_debug "already ran on this image; skipping"
	exit 0
fi

# silently delete files if any exist
./reset.sh "$original_image" > /dev/null 2>&1

# use a regular expression to find the galaxy VCC name and the image filter
# TODO we might need to update this and other parts of the pipeline that assume VCC objects
# if we want to make the pipeline work for other objects
# alternatively, we could invent "fake" VCC numbers for those objects...
galaxy_and_filter="$(get_galaxy_and_filter "$original_image")"

# function to finish up, creating appropriate status file
finish() {
	echo "$1" > "$original_image.status"
	exit 0
}

if [ "$use_flag" = 'true' ]; then
	# convert flag image
	./mask-from-flag.sh "$(sed -e 's/\.fits/_flag.fits/g' <<< "$original_image")"
	# create initial mask from flag image only
	./imcopy.sh "$(sed -e 's/\.fits/_flag_converted.fits/g' <<< "$original_image")" "$original_image.pl"
fi

# generate first pass light model
run_and_log "${name_base}_createmodel1.log" ./create-model.sh "$original_image" "1" || finish 0

# perform subtraction
./imarith.sh "$original_image" "-" "${name_base}_mod1.fits" "${name_base}_modsub1.fits" || finish 0

# generate mask for remaining bright objects
# enters if block if masking failed
if ! run_and_log "${name_base}_mask.log" ./create-mask.sh "${name_base}_modsub1.fits" "${name_base}_mod1.tab" "$use_flag"; then
	# use modsub1 as the final image
	finish 1
else
	echo_debug "running second pass"

	# generate second pass light model
	run_and_log "${name_base}_createmodel2.log" ./create-model.sh "$original_image" "2" || finish 1

	# perform final subtraction
	./imarith.sh "$original_image" "-" "${name_base}_mod2.fits" "${name_base}_modsub2.fits" || finish 1

	# everything successful
	finish 2
fi

# ./cleanup.sh "$original_image"

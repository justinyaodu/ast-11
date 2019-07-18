#!/bin/bash

# implements the complete workflow

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image.fits>"

original_image="$1"

# get directory of original image
work_dir="$(dirname "$original_image")"

# strip .fits extension, but retain galaxy name and directory information
# e.g. "/some/path/VCC1827_i.fits" becomes "/some/path/VCC1827_i"
name_base=${original_image::-5}

# abort if final image already exists
assert_does_not_exist "${name_base}_modsub2.fits"

# use a regular expression to find the galaxy VCC name and the image filter
# TODO we might need to update this and other parts of the pipeline that assume VCC objects
# if we want to make the pipeline work for other objects
# alternatively, we could invent "fake" VCC numbers for those objects...
galaxy_and_filter="$(get_galaxy_and_filter "$original_image")"

# abort if input file doesn't exist
assert_exists "$original_image"

# generate first pass light model
assert_successful ./create-model.sh "$original_image"

# perform subtraction
assert_successful ./subtract.sh "$original_image" "${name_base}_mod1.fits" "${name_base}_modsub1.fits"

# generate mask for remaining bright objects
run_and_log "$work_dir/create-mask.log" assert_successful ./create-mask.sh "${name_base}_modsub1.fits" "${name_base}_mod1.tab"

# generate second pass light model
assert_successful ./create-model.sh "$original_image"

# perform final subtraction
assert_successful ./subtract.sh "$original_image" "${name_base}_mod2.fits" "${name_base}_modsub2.fits"

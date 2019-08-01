#!/bin/bash

# use ISOFIT/Ellipse to generate a galaxy light model
# uses input data from another ISOFIT/Ellipse run
# this script is used when fitting fails for an image in one band
# but a successful fit table is available from an image in another band

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 5 ] || abort "usage: $0 <galaxy_and_filter> <input_image.fits> <output_table.tab> <previous_table.tab>"

galaxy_and_filter="$1"
image_file="$2"
table_file="$3"
previous_table="$4"

log_file="$(strip_extension "$table_file")_fit.log"

# abort if input files don't exist
assert_exists "$image_file" "$previous_table"

# if output file exists, overwrite
remove_if_exists "$table_file"

# generate parameter files
assert_successful ./generate-geompar.sh "$galaxy_and_filter" "$image_file"

# run ISOFIT or Ellipse, depending on configuration
if using_isofit; then
	run_and_log "$log_file" ./isofit-pseudo.cl "$image_file" "$table_file" "$previous_table"
else
	run_and_log "$log_file" ./ellipse-pseudo.cl "$image_file" "$table_file" "$previous_table"
fi

# exit indicating success if table file was created
[ -f "$table_file" ] && exit 0

# exit code 2 for floating point errors, segfaults, etc.
exit 2

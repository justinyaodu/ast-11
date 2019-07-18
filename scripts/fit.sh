#!/bin/bash

# use ISOFIT/Ellipse to generate a galaxy light model

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 5 ] || abort "usage: $0 <galaxy_and_filter> <input_image.fits> <output_table.tab> <harmonics> <object locator threshold>"

galaxy_and_filter="$1"
image_file="$2"
table_file="$3"
harmonics="$4"
ol_threshold="$5"

log_file="$table_file.log"

# abort if input file doesn't exist
assert_exists "$image_file"

# if output file exists, also abort
assert_does_not_exist "$table_file"

# generate parameter files
assert_successful ./generate-geompar.sh "$galaxy_and_filter" "$image_file"
assert_successful ./template-samplepar.sh "$harmonics"
assert_successful ./template-controlpar.sh "$ol_threshold"

# run ISOFIT or Ellipse, depending on configuration
if using_isofit; then
	run_and_log "$log_file" ./isofit.cl "$image_file" "$table_file"
else
	run_and_log "$log_file" ./ellipse.cl "$image_file" "$table_file"
fi

# inspect logs for error messages

# exit code 1 if could not find object center
if grep -q "ERROR: Can not find object center." "$log_file"; then exit 1; fi

# exit code 2 for harmonics-related errors
if grep -q "Error in upper harmonic fit. Please, verify output table."; then exit 2; fi

# exit indicating success if table file was created
[ -f "$table_file" ] && exit 0

# exit code 2 for floating point errors, segfaults, etc.
exit 2

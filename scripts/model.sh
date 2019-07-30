#!/bin/bash

# use bmodel/cmodel to generate an image from a galaxy light model

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <table.tab>"

table_file="$1"

# output image has the same name as the table file, but with a .fits extension
output_image="$(strip_extension "$table_file").fits"

log_file="$(strip_extension "$output_image")_model.log"

# abort if input file doesn't exist
assert_exists "$table_file"

# if output file exists, also abort
assert_does_not_exist "$output_image"

# get background light value from table
background="$(./background.sh "$table_file")"

# create model, running appropriate cl script
if using_isofit; then
	run_and_log "$log_file" ./cmodel.cl "$table_file" "$output_image" "$background" "yes"
else
	run_and_log "$log_file" ./bmodel.cl "$table_file" "$output_image" "$background" "yes"
fi

# if error encountered, try again but do not use higher harmonics
if grep -q "ERROR" "$log_file"; then
	if using_isofit; then
		assert_successful run_and_log "$log_file" timeout 10m ./cmodel.cl "$table_file" "$output_image" "$background" "no"
	else
		assert_successful run_and_log "$log_file" timeout 10m ./bmodel.cl "$table_file" "$output_image" "$background" "no"
	fi
fi

# if an error still encountered, exit indicating failure
if grep -q "ERROR" "$log_file"; then exit 1; fi

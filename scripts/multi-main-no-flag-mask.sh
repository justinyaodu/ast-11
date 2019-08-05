#!/bin/bash

# batch reruns pipeline using main-no-flag-mask.sh

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <directory/containing/galaxy/directories> <list-of-galaxies-to-rerun.txt>"

containing_dir="$(strip_trailing_slash "$1")"

list="$2"
assert_exists "$list"

# loop over everything in directory
for galaxy_dir in "$containing_dir"/*/; do

	# skip if not a directory
	[ -d "$galaxy_dir" ] || continue

	# skip if galaxy not in list
	grep -q "$(basename "$galaxy_dir")" "$list" || continue

	for file in $(find "$galaxy_dir" | grep 'VCC...._..fits$'); do
		# use presence of indicator file as a safe stop signal
		[ -f "STOP" ] && abort "stop file exists"

		print_banner "resetting: $file"

		# reset the run that happened with flag image masking
		./reset.sh "$file"

		# rerun without flag image masking
		./main-no-flag-mask.sh "$file"
	done
done

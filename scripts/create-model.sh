#!/bin/bash

# use fit.sh and model.sh to create a galaxy light model image

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

# run ISOFIT/Ellipse
harmonics="2 3 4 5 6"
ol_threshold="1"

while :; do
	./fit.sh "$(get_galaxy_and_filter "$original_image")" "$original_image" "$output_table" "$harmonics" "$ol_threshold"
	case "$?" in
		# fit.sh did not give any error codes; now check if table data is valid
		0)
			if ./good-fit.sh "$output_table"; then
				echo_debug "output table looks good"
				break
			else
				abort "output table is likely bad"
			fi
			;;
		# could not find object center
		1)
			# if object locator threshold is already zero, give up
			[ "$ol_threshold" = "0" ] && abort "object location failed"

			# decrease object locator threshold
			ol_threshold="$(bc -l <<< "$ol_threshold - 0.25")"
			echo_debug "decreasing object locator threshold to $ol_threshold"

			# try again
			continue
			;;
		# error fitting harmonics
		2)
			# if already at minimum harmonics, exit indicating error
			[ "$harmonics" = "2 3 4" ] && abort "fit failed"

			# decrease the number of harmonics (remove the last two terms)
			harmonics="$(sed -e 's/ [0-9] [0-9]$//g' <<< "$harmonics")"
			echo_debug "using harmonics $harmonics"
			
			# try again
			continue
			;;
		*)
			abort "unknown error"
			;;
	esac
done

# create DS9 region file with isophote ellipses (optional, but nice to have)
./region-from-table.sh "$output_table"

# run bmodel/cmodel
assert_successful ./model.sh "$output_table"

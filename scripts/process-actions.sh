#!/bin/bash

# processes the action list from the second pass of the pipeline

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <directory/containing/galaxy/directories> <inspection.csv>"

containing_dir="$(strip_trailing_slash "$1")"

inspection="$2"
assert_exists "$inspection"

process_action() {
	galaxy_and_filter="$1"
	galaxy="$(grep -o "VCC...." <<< "$galaxy_and_filter")"
	whether_rmf="$2"
	action="$3"

	original_image="$containing_dir/$galaxy/$galaxy_and_filter.fits"

	# if this galaxy image isn't in this dir, then skip it
	if [ ! -f "$original_image" ]; then
		echo_debug "image not in this dir"
		return
	fi

	case "$whether_rmf" in
		TRUE)
			echo_debug "running ring median filter"
			./ring-median.sh "$original_image"
			;;
		FALSE)
			;;
		*)
			abort "illegal value"
			;;
	esac

	case "$action" in
		ignore | ok | ref | bad)
			echo_debug "not running pseudo pipeline"
			;;
		redo)
			echo_debug "running pseudo pipeline"
			reference="$4"
			[ -z "$reference" ] && abort "no reference specified"
			./main-pseudo.sh "$original_image" "$reference"
			;;
		*)
			abort "unknown action: '$action'"
			;;
	esac
}

python process_inspection_spreadsheet.py < "$inspection" | while read -r line; do
	echo_debug "line is '$line'"
	print_banner "$line"
	process_action $line
done

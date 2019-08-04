#!/bin/bash

# processes the action list from the second pass of the pipeline

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <directory/containing/galaxy/directories> <actions.csv>"

containing_dir="$(strip_trailing_slash "$1")"
actions="$2"

assert_exists "$actions"

process_action() {
	galaxy_and_filter="$1"
	galaxy="$(grep -o "VCC...." <<< "$galaxy_and_filter")"
	action="$2"

	original_image="$containing_dir/$galaxy/$galaxy_and_filter.fits"

	# if this galaxy image isn't in this dir, then skip it
	if [ ! -f "$original_image" ]; then
		echo_debug "image not in this dir"
		return
	fi

	case "$action" in
		ignore | copy)
			echo_debug "doing nothing"
			;;
		redo)
			echo_debug "running pseudo pipeline"
			reference="$3"
			./main-pseudo.sh "$original_image" "$reference"
			;;
		rmf)
			echo_debug "running ring median filter"
			./ring-median.sh "$original_image"
			;;
		*)
			abort "unknown action: '$action'"
			;;
	esac
}

sed -e 's/\r$//g' < "$actions" | while read -r line; do
	line="$(sed -e 's/,/ /g' <<< "$line")"
	process_action $line
done

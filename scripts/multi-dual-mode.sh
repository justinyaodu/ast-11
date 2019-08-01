#!/bin/bash

# runs dual mode on multiple galaxies

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 3 ] || abort "usage: $0 <galaxy_and_filter_list.txt> <directory/containing/galaxy/directories> <catalog/directory>"

list="$1"
assert_exists "$list"

galaxy_dir_dir="$2"
catalog_dir="$3"
assert_directory_exists "$galaxy_dir_dir" "$catalog_dir"

process_galaxies() {
	true
	# echo "    process $@"
	# ./dual-mode.sh "$galaxy_dir_dir" "$catalog_dir" $@
}

galaxy=''
chunk=''
# use sed to remove carriage returns
sed -e 's/\r$//g' < "$list" | while read -r line; do
	# galaxy of current line
	new_galaxy="$(grep -o 'VCC....' <<< "$line")"

	#echo old $galaxy new $new_galaxy

	# if it matches current chunk galaxy
	if [ "$new_galaxy" = "$galaxy" ]; then
		echo "chunk before: '$chunk'"
		chunk="$chunk $line"
		echo "chunk after : '$chunk'"
	else
		# process old chunk, if chunk not empty
		[ -z "$chunk" ] || process_galaxies $chunk

		galaxy="$new_galaxy"
		echo "chunk before: '$chunk'"
		chunk="$line"
		echo "chunk after : '$chunk'"
	fi
done

# take care of last chunk
process_galaxies $chunk

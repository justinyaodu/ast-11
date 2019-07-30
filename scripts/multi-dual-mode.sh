#!/bin/bash

# runs dual mode on multiple galaxies

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory/containing/galaxy/directories>"

# remove trailing slash on directory, if any
# makes no practical difference, but looks nicer when printing
containing_dir="$(sed -e 's/\/$//g' <<< "$1")"

for galaxy_dir in "$containing_dir"/*; do
	
	[ -d "$galaxy_dir" ] || continue

	./dual-mode.sh "$galaxy_dir"
done

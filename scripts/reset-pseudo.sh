#!/bin/bash

# remove all files from subtraction pipeline, leaving only original files

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image>"

original_image="$1"
directory="$(dirname "$1")"

galaxy_and_filter="$(get_galaxy_and_filter "$original_image")"

for suffix in "_createmodel3.log"; do
	rm "$directory/$galaxy_and_filter$suffix"
done
#!/bin/bash

# cleanup intermediary files from subtraction pipeline to save disk space

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory>"

directory="$1"
[ -d "$directory" ] || abort "is not a directory"

galaxy_and_filter="$(get_galaxy_and_filter "$(ls "$directory" | grep "VCC" | head -n 1)")"

for item in "_mod1.fits" "_modsub1.fits" "_seg.fits" ".fits.pl" "_mod2.fits"; do
	rm "$directory/$galaxy_and_filter$item"
done

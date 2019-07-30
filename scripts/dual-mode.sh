#!/bin/bash

# uses SExtractor dual mode to perform multi-band photometry on modsub2 images

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory/containing/modsub2/images>"

directory="$(strip_trailing_slash "$1")"
assert_directory_exists "$directory"

# make sure modsub2 images exist
ls "$directory"/*modsub2.fits 2>&1 > /dev/null || abort "no modsub2 images in directory"

# get galaxy name
galaxy="$(get_galaxy_and_filter "$(ls "$directory"/*modsub2.fits | head -n 1)" | grep -o '^VCC....')"

# identify object detection image
for band in 'g' 'u' 'i' 'r' 'z'; do
	# attempt to use this image
	detect_image="$directory/${galaxy}_${band}_modsub2.fits"

	# if image found, exit loop
	[ -f "$detect_image" ] && break
done

echo_debug "using detection image: $detect_image"

detect_weight="$(sed -e 's/\_modsub2.fits/_sig.fits/g' <<< "$detect_image")"
detect_flag="$(sed -e 's/\_modsub2.fits/_flag.fits/g' <<< "$detect_image")"

for measure_image in "$directory"/*modsub2.fits; do
	measure_weight="$(sed -e 's/\_modsub2.fits/_sig.fits/g' <<< "$measure_image")"
	measure_flag="$(sed -e 's/\_modsub2.fits/_flag.fits/g' <<< "$measure_image")"

	catalog_file="$directory/$(get_galaxy_and_filter "$measure_image").cat"

	# if catalog already exists and newer than modsub2 images, skip
	if [ -f "$catalog_file" ] && [ "$catalog_file" -nt "$detect_image" ] && [ "$catalog_file" -nt "$measure_image" ]; then
		echo_debug "skipping, catalog up to date"
		continue
	fi

	print_banner "processing $measure_image"

	assert_successful sextractor "$detect_image","$measure_image" -c ngvs.sex -WEIGHT_IMAGE "$detect_weight","$measure_weight" -FLAG_IMAGE "$detect_flag","$measure_flag" -CATALOG_NAME "$catalog_file"
done

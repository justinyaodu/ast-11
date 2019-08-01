#!/bin/bash

# uses SExtractor dual mode to perform multi-band photometry on modsub2 images

source common.sh

# print usage message if number of parameters is incorrect
[ $# -ge 3 ] || abort "usage: $0 <directory/containing/galaxy/directories> <catalog/output/dir> <galaxy_and_filter_1> [galaxy_and_filter_2] ..."

directory="$(strip_trailing_slash "$1")"
assert_directory_exists "$directory"

catalog_directory="$(strip_trailing_slash "$2")"
assert_directory_exists "$catalog_directory"

shift 2

# identify object detection image
for band in 'g' 'i' 'z' 'u' 'r'; do
	detect="$(grep -o "VCC...._${band}" <<< "$@")" && break
done

echo_debug "detecting with: $detect"

get_modsub2() {
	echo "$directory"/"$(grep -o 'VCC....' <<< "$1")"/"$1_modsub2.fits"
}

detect_image="$(get_modsub2 "$detect")"

detect_weight="$(sed -e 's/\_modsub2.fits/_sig.fits/g' <<< "$detect_image")"
detect_flag="$(sed -e 's/\_modsub2.fits/_flag.fits/g' <<< "$detect_image")"

for measure in $@; do
	measure_image="$(get_modsub2 "$measure")"

	measure_weight="$(sed -e 's/\_modsub2.fits/_sig.fits/g' <<< "$measure_image")"
	measure_flag="$(sed -e 's/\_modsub2.fits/_flag.fits/g' <<< "$measure_image")"

	catalog_file="$catalog_directory/$measure.cat"

	# if catalog already exists and newer than modsub2 images, skip
	if [ -f "$catalog_file" ] && [ "$catalog_file" -nt "$detect_image" ] && [ "$catalog_file" -nt "$measure_image" ]; then
		echo_debug "skipping, catalog up to date"
		continue
	fi

	print_banner "processing $measure_image"

	assert_successful sextractor "$detect_image","$measure_image" -c ngvs.sex -WEIGHT_IMAGE "$detect_weight","$measure_weight" -FLAG_IMAGE "$detect_flag","$measure_flag" -CATALOG_NAME "$catalog_file"
done

#!/bin/bash

# uses SExtractor dual mode to perform multi-band photometry

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image.fits>"

measure_original="$1"
detect_original="$(sed -e 's/_[ugriz].fits/_g.fits/g' <<< "$measure_original")"

measure_image="$(get_best "$measure_original")"
detect_image="$(get_best "$detect_original")"
assert_exists "$detect_image" "$measure_image"

detect_weight="$(sed -e 's/.fits$/_sig.fits/g' <<< "$detect_original")"
detect_flag="$(sed -e 's/.fits$/_flag.fits/g' <<< "$detect_original")"
assert_exists "$detect_weight" "$detect_flag"

measure_weight="$(sed -e 's/.fits$/_sig.fits/g' <<< "$measure_original")"
measure_flag="$(sed -e 's/.fits$/_flag.fits/g' <<< "$measure_original")"
assert_exists "$measure_weight" "$measure_flag"

catalog_file="$(dirname "$measure_image")/$(grep -o 'VCC...._[ugriz]' <<< "$measure_image").cat"
remove_if_exists "$catalog_file"

assert_successful sextractor "$detect_image","$measure_image" -c ngvs.sex -WEIGHT_IMAGE "$detect_weight","$measure_weight" -FLAG_IMAGE "$detect_flag","$measure_flag" -CATALOG_NAME "$catalog_file"

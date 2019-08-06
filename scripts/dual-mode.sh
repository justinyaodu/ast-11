#!/bin/bash

# uses SExtractor dual mode to perform multi-band photometry

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image.fits.dual>"

grep -q '\.fits\.dual$' <<< "$1" || abort "not a .fits.dual file: $1"

measure_dual="$1"
detect_dual="$(sed -e 's/_[ugriz].fits.dual/_g.fits.dual/g' <<< "$1")"
assert_exists "$detect_dual" "$measure_dual"

detect_image="$(dirname "$detect_dual")/$(<"$detect_dual")"
measure_image="$(dirname "$measure_dual")/$(<"$measure_dual")"
assert_exists "$detect_image" "$measure_image"

detect_weight="$(sed -e 's/.fits.dual/_sig.fits/g' <<< "$detect_dual")"
detect_flag="$(sed -e 's/.fits.dual/_flag.fits/g' <<< "$detect_dual")"
assert_exists "$detect_weight" "$detect_flag"

measure_weight="$(sed -e 's/.fits.dual/_sig.fits/g' <<< "$measure_dual")"
measure_flag="$(sed -e 's/.fits.dual/_flag.fits/g' <<< "$measure_dual")"
assert_exists "$measure_weight" "$measure_flag"

catalog_file="$(dirname "$measure_image")/$(grep -o 'VCC...._[ugriz]' <<< "$measure_image").cat"
remove_if_exists "$catalog_file"

assert_successful sextractor "$detect_image","$measure_image" -c ngvs.sex -WEIGHT_IMAGE "$detect_weight","$measure_weight" -FLAG_IMAGE "$detect_flag","$measure_flag" -CATALOG_NAME "$catalog_file"

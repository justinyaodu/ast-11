#!/bin/bash

# implements the complete workflow

source common.sh

# print error message if we suspect that the user has not activated the conda environment
[ -n "$(type -P ds9)" ] || abort "conda environment is not activated"

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image.fits>"

original_image="$1"

# strip .fits extension
name_base=${original_image::-5}

galaxy_and_filter="$(basename "$original_image" | grep -o "VCC[0-9][0-9][0-9][0-9]_[ugriz]")"

# abort if input file doesn't exist
assert_exists "$original_image"

# generate first pass light model
./isofit.sh "$galaxy_and_filter" "$original_image" "${name_base}_mod1.tab" "2 3 4"

# create image from first pass light model
./cmodel.sh "${name_base}_mod1.tab" "${name_base}_mod1.fits"

# perform subtraction
./subtract.sh "$original_image" "${name_base}_mod1.fits" "${name_base}_modsub1.fits"

# generate mask for remaining bright objects
./create-mask.sh "${name_base}_modsub1.fits"

# generate first pass light model
./isofit.sh "$galaxy_and_filter" "$original_image" "${name_base}_mod2.tab" "2 3 4"

# create image from second pass light model
./cmodel.sh "${name_base}_mod2.tab" "${name_base}_mod2.fits"

# perform final subtraction
./subtract.sh "$original_image" "${name_base}_mod2.fits" "${name_base}_modsub2.fits"

#!/bin/bash

# implements the complete workflow

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <original_image.fits>"

original_image="$1"

# strip .fits extension
name_base=${original_image::-5}

galaxy_and_filter="$(basename "$original_image" | grep -o "VCC[0-9][0-9][0-9][0-9]_[ugriz]")"

# abort if input file doesn't exist
assert_exists "$original_image"

# generate first pass light model
if using_isofit; then
	./isofit.sh "$galaxy_and_filter" "$original_image" "${name_base}_mod1.tab" "2 3 4" "0.2"
else
	./ellipse.sh "$galaxy_and_filter" "$original_image" "${name_base}_mod1.tab" "" "1"
fi

# create image from first pass light model
if using_isofit; then
	./cmodel.sh "${name_base}_mod1.tab" "${name_base}_mod1.fits"
else
	./bmodel.sh "${name_base}_mod1.tab" "${name_base}_mod1.fits"
fi

# perform subtraction
./subtract.sh "$original_image" "${name_base}_mod1.fits" "${name_base}_modsub1.fits"

# generate mask for remaining bright objects
./create-mask.sh "${name_base}_modsub1.fits"

# generate second pass light model
if using_isofit; then
	./isofit.sh "$galaxy_and_filter" "$original_image" "${name_base}_mod2.tab" "2 3 4" "0.2"
else
	./ellipse.sh "$galaxy_and_filter" "$original_image" "${name_base}_mod2.tab" "" "1"
fi

# create image from second pass light model
if using_isofit; then
	./cmodel.sh "${name_base}_mod2.tab" "${name_base}_mod2.fits"
else
	./bmodel.sh "${name_base}_mod2.tab" "${name_base}_mod2.fits"
fi

# perform final subtraction
./subtract.sh "$original_image" "${name_base}_mod2.fits" "${name_base}_modsub2.fits"

#!/bin/bash

# generate a DS9 region file from catalog data to outline where the
# catalog data shows the galaxy is

source common.sh

# function to generate a region file
generate_region_file() {
	x=$1
	y=$2
	ell=$3
	pa=$4
	smaj=$5
	file=$6

	# semi major and semi minor axes in arcsec
	smin=$(bc -l <<< "$smaj * (1 - $ell)")

	# convert pa to image rotation
	pa=$(bc -l <<< "$pa * (-1)")

	# convert to pixels
	smaj=$(bc -l <<< "$smaj / 0.187" | head -c 8)
	smin=$(bc -l <<< "$smin / 0.187" | head -c 8)

	# output to file
	cat > "$file" <<- EOF
		# Region file format: DS9 version 4.1
		global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1
		image
		ellipse($x,$y,$smaj,$smin,$pa) #text={pa} color=red
		ellipse($x,$y,$smaj,$smin,$(bc -l <<< "- $pa" | head -c 5)) #text={neg pa} color=#f80
		ellipse($x,$y,$smaj,$smin,$(bc -l <<< "90 + $pa" | head -c 5)) #text={90 plus pa} color=yellow
		ellipse($x,$y,$smaj,$smin,$(bc -l <<< "90 - $pa" | head -c 5)) #text={90 minus pa} color=green
		ellipse($x,$y,$smaj,$smin,$(bc -l <<< "180 + $pa" | head -c 5)) #text={180 plus pa} color=blue
		ellipse($x,$y,$smaj,$smin,$(bc -l <<< "180 - $pa" | head -c 5)) #text={180 minus pa} color=pink
		ellipse($x,$y,$smaj,$smin,$(bc -l <<< "270 + $pa" | head -c 5)) #text={270 plus pa} color=#80f
		ellipse($x,$y,$smaj,$smin,$(bc -l <<< "270 - $pa" | head -c 5)) #text={270 minus pa} color=#888
	EOF
}

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <image.fits>"

image_file="$1"
region_file="$image_file.reg"

assert_exists "$image_file"
assert_does_not_exist "$region_file"

center="$(python -c "import fits_center; fits_center.get_fits_center(\"$image_file\")")"

galaxy_and_filter="$(grep -o "VCC[0-9][0-9][0-9][0-9]_[ugriz]" <<< "$image_file")"
properties="$(python -c "import read_catalog; ell, pa, sma = read_catalog.read_properties(\"$galaxy_and_filter\", \"gal_list.cat\"); print ell, pa, sma")"

generate_region_file $center $properties "$region_file"
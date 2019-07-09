#!/bin/bash

# looks up appropriate initial values for geometric parameters using catalog data

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <galaxyname_filter> <image.fits>"

catalog_file="fake_list.cat"
galaxy_and_filter="$1"
image_file="$2"

assert_exists "$catalog_file" "$image_file"

# call Python scripts to get properties

# x and y position of galaxy center
position="$(python -c "import fits_center; fits_center.get_fits_center(\"$image_file\")")"

# get conversion from arcseconds to pixels for this image
arcsec_to_px="$(python -c "import arcsec_to_px; arcsec_to_px.arcsec_to_px(\"$image_file\")")"
echo_debug conversion factor is $arcsec_to_px

# ellipticity, position angle, initial sma, min sma, max sma
shape_properties="$(python -c "import read_catalog; read_catalog.get_properties(\"$galaxy_and_filter\", \"$catalog_file\", $arcsec_to_px)")"

# log parameters for debugging purposes
echo_debug "x y ell pa sma0 minsma maxsma: $position $shape_properties"

./template-geompar.sh $position $shape_properties

#!/bin/bash

# looks up appropriate initial values for geometric parameters using catalog data

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <galaxyname_filter> <image.fits>"

catalog_file="gal_list_all.cat"
galaxy_and_filter="$1"
image_file="$2"

# call Python scripts to get properties

# ellipticity, position angle, initial sma, min sma, max sma
assert_exists "$catalog_file"
shape_properties="$(python -c "import read_catalog; read_catalog.get_properties(\"$galaxy_and_filter\", \"$catalog_file\")")"

# if catalog wasn't read successfully, abort
if [ -z "$shape_properties" ]; then
	abort "could not obtain catalog data"
fi
echo_debug "ell pa sma0 minsma maxsma: $shape_properties"

# x and y position of galaxy center
assert_exists "$image_file"
position="$(python -c "import fits_center; fits_center.get_fits_center(\"$image_file\")")"
echo_debug "x y: $position"

./template-geompar.sh $position $shape_properties

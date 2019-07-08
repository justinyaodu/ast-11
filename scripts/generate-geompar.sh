#!/bin/bash

# looks up appropriate initial values for geometric parameters using catalog data

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <galaxy-name_filter> <image.fits>"

catalog_file="gal_list.cat"
galaxy_and_filter="$1"
image_file="$2"

assert-exists "$catalog_file" "$image_file"

# call Python scripts to get properties

# x and y position of galaxy center
position="$(python -c "import fits_center; fits_center.get_fits_center(\"$image_file\")")"

# ellipticity, position angle, initial sma, min sma, max sma
shape_properties="$(python -c "import read_catalog; read_catalog.get_properties(\"$galaxy_and_filter\", \"$catalog_file\")")"

# log parameters for debugging purposes
echo-debug "x y ell pa sma0 minsma maxsma: $position $shape_properties"

./template-geompar.sh $position $shape_properties

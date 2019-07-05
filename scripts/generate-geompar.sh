#!/bin/bash

# looks up appropriate initial values for geometric parameters using catalog data
# and generates reasonable min and max values

# print usage message if number of parameters is incorrect
if [ "$#" -ne 2 ]; then
	>&2 echo "usage: $0 <galaxy-name_filter> <image.fits>"
	>&2 echo "  e.g. $0 VCC1720_i VCC1720_i.fits"
	exit 1
fi

catalog="gal_list.cat"
galaxy_and_filter="$1"
image_file="$2"

# abort if image file doesn't exist
if [ ! -f $image_file ]; then
	>&2 echo "error: image file does not exist"
	exit 1
fi

# call Python scripts to get properties
shape_properties="$(python -c "import read_catalog; read_catalog.get_properties(\"$galaxy_and_filter\", \"$catalog\")")"
position="$(python -c "import fits_center; fits_center.get_fits_center(\"$galaxy_and_filter.fits\")")"

./template-geompar.sh $position $shape_properties

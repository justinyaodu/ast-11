#!/bin/bash

# open catalog files

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <galaxyname_NGVS_cat.fits> <sextractor_catalog_file>"

fits_catalog_file="$1"
sex_catalog_file="$2"

# abort if input file doesn't exist
assert_exists "$fits_catalog_file" "$sex_catalog_file"

# call Python script
python -c "import open_cat_files; open_cat_files.read_catalog(\"$fits_catalog_file\",\"$sex_catalog_file\")"

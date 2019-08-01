#!/bin/bash

# open catalog files

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <galaxyname_NGVS_cat.fits>"

catalog_file="$1"

# abort if input file doesn't exist
assert_exists "$catalog_file"

# call Python script
python -c "import open_cat_files; open_cat_files.read_catalog()"

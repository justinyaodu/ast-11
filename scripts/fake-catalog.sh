#!/bin/bash

# generates "fake" catalog data from an ISOFIT galaxy light model

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <table.tab>"

table_file="$1"
dump_file=".model_table_dump"

assert_exists "$table_file"
remove_if_exists "$dump_file"

# dump table data; replace INDEFs with dummy values
./tprint.sh "$table_file" "SMA,ELLIP,PA" | sed -e "s/INDEF/-123.4/g" > "$dump_file"

# run Python script to output values
python -c "import fake_catalog; fake_catalog.get_fake_data(\"$dump_file\")"

rm "$dump_file"

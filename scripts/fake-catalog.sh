#!/bin/bash

# generates "fake" catalog data from an ISOFIT galaxy light model

source common.sh

# print usage message if number of parameters is incorrect
if [ "$#" -ne 1 ]; then
	>&2 echo "usage: $0 <table.tab>"
	exit 1
fi

table_file="$1"
dump_file=".model_table_dump"

assert-exists "$table_file"
remove-if-exists "$dump_file"

# dump table data; replace INDEFs with dummy values
./tprint.sh "$table_file" "SMA,ELLIP,PA" | sed -e "s/INDEF/-123.4/g" > "$dump_file"

python -c "import fake_catalog; fake_catalog.get_fake_data(\"$dump_file\")"

rm "$dump_file"

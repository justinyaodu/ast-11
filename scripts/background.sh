#!/bin/bash

# use the outermost intensity value from an Ellipse/ISOFIT model
# as the background light value

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <table.tab>"

table_file="$1"
dump_file=".background_table_dump"

assert_exists "$table_file"

remove_if_exists "$dump_file"

# dump table data to file
# discard console output (package import banners and such)
./background.cl "$table_file" "$dump_file" > /dev/null

# print last line, trim whitespace
tail -n 1 < "$dump_file" | xargs

# delete dump file
rm "$dump_file"

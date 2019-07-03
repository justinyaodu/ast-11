#!/bin/bash

# use the outermost intensity value from an Ellipse/ISOFIT model
# as the background light value

source common.sh

# print usage message if number of parameters is incorrect
if [ "$#" -ne 1 ]; then
	>&2 echo "Usage: $0 <tablefile>"
	exit 1
fi

tablefile="$1"
dumpfile=".background_table_dump"

# if table file doesn't exist, abort
if [ ! -f "$tablefile" ]; then
	>&2 echo "$0: error: table file does not exist"
	exit 1
fi

# if dump file exists, remove it
if [ -f "$dumpfile" ]; then
	>&2 echo "$0: warning: dump file already exists, removing"
	rm "$dumpfile"
fi

# dump table data to file
# discard console output (package import banners and such)
"./background.cl" "$tablefile" "$dumpfile" > /dev/null

# print last line, trim whitespace
tail -n 1 < "$dumpfile" | xargs

# delete dump file
rm "$dumpfile"

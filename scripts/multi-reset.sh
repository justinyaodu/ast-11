#!/bin/bash

# remove all files from subtraction pipeline, leaving only original files

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <dir/to/reset>"

echo "resetting dir: $1"
read -p "please retype dir name to confirm: " -r line
[ "$line" = "$1" ] || abort "dir names do not match!"

for original in $(find "$1" | grep 'VCC...._..fits$'); do
	./reset.sh "$original"
done

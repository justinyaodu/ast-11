#!/bin/bash

# batch cleanup unneeded files

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <dir/to/cleanup>"

for original in $(find "$1" | grep 'VCC...._..fits$'); do
	./cleanup.sh "$original"
done

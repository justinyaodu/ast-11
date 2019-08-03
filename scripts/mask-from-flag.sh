#!/bin/bash

# convert a flag image (1 for good data, 0 for ignore)
# to resemble a seg image (0 for good data, positive for ignore)

source common.sh

[ $# -eq 1 ] || abort "usage: $0 <flag.fits>"

flag_image="$1"
assert_exists "$flag_image"

output_image="$(sed -e 's/\.fits$/_converted.fits/g' <<< "$flag_image")"

assert_successful ./imarith.sh "1" "-" "$flag_image[1]" "$output_image"

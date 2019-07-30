#!/bin/bash

# slideshows modsub2 images to facilitate human verification of proper light subtraction

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory/containing/galaxy/directories>"

# start DS9
echo_debug "starting DS9..."
ds9 &

# wait for DS9 to start
while ! ds9_xpa_running; do sleep 1; done

# loop over all modsub2 images
for image in "$1"/*/*modsub2*; do
	assert_successful ./inspect.sh "$image"

	# press Enter to view next image
	read -p "current: $image (press Enter)"
done

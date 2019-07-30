#!/bin/bash

# slideshows modsub2 images to facilitate human verification of proper light subtraction

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <directory/containing/galaxy/directories>"

# remove trailing slash on directory, if any
# makes no practical difference, but looks nicer when printing
containing_dir="$(sed -e 's/\/$//g' <<< "$1")"

# start DS9 if not running
if ! ds9_xpa_running; then
	echo_debug "starting DS9..."
	ds9 &

	# wait for DS9 to start
	while ! ds9_xpa_running; do sleep 1; done
fi

# loop over all modsub2 images
for image in $(find "$containing_dir" | grep "modsub2.fits"); do
	assert_successful ./inspect.sh "$image"

	# press Enter to view next image
	read -p "current: $image (press Enter)"
done

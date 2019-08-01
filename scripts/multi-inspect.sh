#!/bin/bash

# slideshows modsub2 images to facilitate human verification of proper light subtraction

source common.sh

# print usage message if number of parameters is incorrect
[ $# -ge 1 ] || abort "usage: $0 <directory/containing/galaxy/directories> [filename filter, defaults to modsub2.fits]"

containing_dir="$(strip_trailing_slash "$1")"
if [ -z "$2" ]; then
	file_filter='modsub2.fits'
else
	file_filter="$2"
fi

# start DS9 if not running
if ! ds9_xpa_running; then
	echo_debug "starting DS9..."
	ds9 &

	# wait for DS9 to start
	while ! ds9_xpa_running; do sleep 1; done
fi

search_for=''

# loop over all modsub2 images
for image in $(find "$containing_dir" | grep "$file_filter" | sort); do
	# if image does not match search string
	if ! grep -q "$search_for" <<< "$image"; then
		echo "    skipping $image: does not match search string $search_for"
		continue
	fi

	assert_successful ./inspect.sh "$image"
	assert_successful ./inspect-circles.sh "$image"

	# press Enter to view next image
	echo "current: $image"
	read -p "enter search string, or press Enter for next: " search_for
done

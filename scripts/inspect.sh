#!/bin/bash

# displays a FITS image in a running DS9 instance

source common.sh

# print usage message if number of parameters is incorrect
[ $# -ge 1 ] || "usage: $0 <modsub2_image.fits> [another_image.fits] ..."
	
# check xpa to make sure DS9 is running
if ! ds9_xpa_running; then abort "DS9 is not running"; fi

xpaset -p ds9 frame delete all

frame_count='0'
while [ "$1" != '' ]; do
	image="$1"

	# abort if input file doesn't exist
	assert_exists "$image"

	((frame_count++))

	xpaset -p ds9 frame new
	xpaset -p ds9 fits "$image"
	xpaset -p ds9 scale mode zscale

	# load region file, if it exists
# 	region_file="$(sed -e 's/_modsub2\.fits$/_mod2.reg/g' <<< "$image")"
# 	if [ -f "$region_file" ]; then
# 		tempfile="$(tempfile)"
# 		sed -e 's/ #text=.*$//g' < "$region_file" | awk 'NR % 3 == 1' > "$tempfile"
# 		xpaset -p ds9 regions load "$tempfile"
# 	fi

	shift
done

xpaset -p ds9 tile yes
	
while [ "$frame_count" -ge 0 ]; do
	xpaset -p ds9 zoom to fit
	xpaset -p ds9 frame prev
	((frame_count--))
done

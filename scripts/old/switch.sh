#!/bin/bash

# switch between isofit and ellipse

source common.sh

if [ "$1" == "isofit" ] || [ "$1" == "ellipse" ]; then
	pushd ~/miniconda2/envs/iraf27/iraf_extern/ > /dev/null
	rm stsdas
	ln -s "stsdas$1/" "stsdas"
	echo_debug "now using $1"
	popd > /dev/null

	# add file which indicates whether isofit is being used
	if [ "$1" == "isofit" ]; then
		touch ".using-isofit"
	else
		rm -f ".using-isofit"
	fi
else
	abort "usage: $0 <isofit|ellipse>"
fi

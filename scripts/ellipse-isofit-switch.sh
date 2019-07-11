#!/bin/bash

# switch between isofit and ellipse

source common.sh

if [ "$1" == "isofit" ] || [ "$1" == "ellipse" ]; then
	cd ~/miniconda2/envs/iraf27/iraf_extern/
	rm stsdas
	ln -s "stsdas$1/" "stsdas"
	echo_debug "Now using $1"
else
	abort "Usage: $0 <isofit|ellipse>"
fi

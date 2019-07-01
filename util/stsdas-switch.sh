#!/bin/bash

if [ "$1" == "isofit" ] || [ "$1" == "ellipse" ]
then
	cd ~/miniconda2/envs/iraf27/iraf_extern/
	rm stsdas
	ln -s stsdas$1/ stsdas
	echo "Now using $1"
else
	echo "Usage: $0 <isofit|ellipse>"
	exit 1
fi


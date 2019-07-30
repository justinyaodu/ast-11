#!/bin/bash

# outputs final status of each image processed by subtraction pipeline
# generates status.csv file in current directory

source common.sh

[ $# -eq 1 ] || abort "usage: $0 <directory/containing/galaxy/directories>"

dir="$1"
[ -d "$dir" ] || abort "not a directory: $dir"

cd "$dir"

{
	echo "Image,Status"

	for galaxy_dir in *; do

		# skip if not a directory
		[ -d "$galaxy_dir" ] || continue

		for band in 'g' 'i' 'r' 'u' 'z'; do
			name="${galaxy_dir}_${band}"
			original_image="${galaxy_dir}/$name.fits"

			if [ ! -f "$original_image" ]; then
				echo "$name,no image"
				continue
			fi

			if [ -f "$original_image.failed" ]; then
				echo "$name,failed"
				continue
			fi

			modsub2="${galaxy_dir}/${name}_modsub2.fits"
			if [ -f "$modsub2" ]; then
				echo "$name,successful"
				continue
			fi

			echo "$name,not run"
		done
	done
} > "status.csv"

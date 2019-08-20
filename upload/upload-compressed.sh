#!/bin/bash

echo "this script is incomplete, don't use it for anything :)"
exit 1

[ -d "$1" ] || { >&2 echo "not a directory: '$1'"; exit 1; }

parent_dir="$1"

mkdir "$parent_dir/uploaded"

# directory to copy to on server
copy_to='/net/phizo/data/d/AST-02/AST-11/certain_subtracted'

# get galaxy directories
for galaxy_dir in "$parent_dir"/VCC????/; do

	# abort if stop file exists
	[ -f "STOP" ] && { >&2 echo "stop file exists"; exit 0; }
	
	basename="$(basename "$galaxy_dir")"
	archive="$basename.tar.gz"

	>&2 tar -C "$parent_dir" -czvf "$basename.tar.gz" "$basename"

	echo "put $parent_dir/$archive $copy_to"

	mv "$galaxy_dir" "$parent_dir"/uploaded
	rm "$parent_dir/$basename.tar.gz"
	
done | sftp -R 256 -B 65536 gst131@ssh.ucolick.org

#!/bin/bash

>&2 echo "unknown if this script works! mainly here for reference"
exit 1

[ -d "$1" ] || { >&2 echo "not a directory: '$1'"; exit 1; }

parent_dir="$1"

uploaded="$parent_dir/uploaded"
mkdir "$uploaded"

# directory to copy to on server
copy_to='/net/phizo/data/d/AST-02/AST-11/certain_subtracted'

# get galaxy directories
for galaxy_dir in "$parent_dir"/VCC????/; do

	# abort if stop file exists
	[ -f "STOP" ] && { >&2 echo "stop file exists"; echo "exit"; exit 0; }
	
	basename="$(basename "$galaxy_dir")"

	echo "mkdir $copy_to/$basename"

	for file in "$galaxy_dir"/*; do
		put_command="put $file $copy_to/$basename/"
		echo "$put_command"
		>&2 echo "$put_command"
	done

	echo "!mv $galaxy_dir $uploaded"

	# wait for this directory to be moved before continuing
	# otherwise, the SFTP commands to transfer everything will all
	# be queued, and it will be impossible to interrupt safely
	while [ -d "$galaxy_dir" ]; do sleep 1; done

done | sed -u 's/\/\//\//g' | sftp gst131@ssh.ucolick.org

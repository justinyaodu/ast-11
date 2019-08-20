#!/bin/bash

[ -d "$1" ] || { >&2 echo "not a directory: '$1'"; exit 1; }

parent_dir="$1"

uploaded="$parent_dir/uploaded"
[ -d "$uploaded" ] || mkdir "$uploaded"

# directory to copy to on server
copy_to='/net/phizo/data/d/AST-02/AST-11/certain_subtracted'

# get galaxy directories
for archive in "$parent_dir"/VCC????.tar.gz; do

	# abort if stop file exists
	[ -f "STOP" ] && { >&2 echo "stop file exists"; echo "exit"; exit 0; }
	
	for sftp_command in "put $archive $copy_to/" "!mv $archive $uploaded"; do
		echo "$sftp_command"
		>&2 echo "$sftp_command"
	done

	# wait for this archive to be transferred before continuing
	# otherwise, the SFTP commands to transfer everything will all
	# be queued, and it will be impossible to interrupt safely
	while [ -f "$archive" ]; do sleep 1; done

done | sed -u 's/\/\//\//g' | sftp gst131@ssh.ucolick.org

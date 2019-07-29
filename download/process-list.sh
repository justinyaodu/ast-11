#!/bin/bash

# prompt user for whether to download list
read -p "update list.txt? [y/n] " -n 1 update

if [ "$update" = "y" ]; then
	echo "updating list.txt"
	# copy list.txt from server to current folder
	scp gst131@ssh.ucolick.org:/net/phizo/data/d/AST-02/certain/list.txt .
else
	echo "skipping update of list.txt"
fi

{
	# for every galaxy directory present in the current directory
	for galaxy_dir in VCC????; do
		
		# find all files for this galaxy which are present on the server
		grep "$galaxy_dir" "list.txt" | {

			# read each line of text from pipe
			while read -r line; do

				# extract the timestamp and the file name
				timestamp="$(echo "$line" | grep -o "^[0-9]*")"
				file="$(echo "$line" | sed -e 's/^[0-9]* //g')"
				
				# get just the filename (without the path)
				file_basename="$(basename "$file")"
				
				# the local file corresponding to the file on the server
				local_file="$galaxy_dir/$file_basename"

				# if file exists on server but not here,
				# mark for download
				if [ ! -f "$local_file" ]; then
					echo "$file"
				else
					local_timestamp="$(stat --printf="%Y" "$local_file")"
					
					# if local file is outdated
					if [ "$local_timestamp" -lt "$timestamp" ]; then
						echo "$file"
					fi
				fi
			done
		}
	done
} | {
	# this section creates a SFTP command from the file path
	while read -r file; do
		# sed strips the long/ directory from path, if it is there
		echo "get \"/net/phizo/data/d/AST-02/certain/$file\" \"$(echo "$file" | sed -e 's/long\///g')\""
	done
# and sftp downloads the files from the server
} | sftp -R 256 -B 65536 gst131@ssh.ucolick.org

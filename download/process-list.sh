#!/bin/bash

# temporary file containing SFTP commands to download files that need updating
sftp_commands=".sftp-commands"

# prompt user for whether to download list
read -p "update list.txt? [y/n] " update

if [ "$update" = "y" ]; then
	echo "updating list.txt"
	# copy list.txt from server to current folder
	scp gst131@ssh.ucolick.org:/net/phizo/data/d/AST-02/certain/list.txt .
else
	echo "skipping update of list.txt"
fi

echo "updating images..."
{
	# for every galaxy directory present in the current directory
	for galaxy_dir in VCC????; do
		
		# find all files for this galaxy which are present on the server
		grep "$galaxy_dir" "list.txt" | {

			# read each line of text from pipe
			while read -r line; do

				# skip imUrlList.txt files
				grep -q 'imUrlList.txt$' <<< "$line" && continue

				# extract the timestamp, file size, and file name
				timestamp="$(echo "$line" | grep -o "^[0-9]*")"

				# pipe through xargs to trim whitespace
				filesize="$(echo "$line" | grep -o " [0-9]* " | xargs)"
				
				file="$(echo "$line" | sed -e 's/^[0-9]* [0-9]* //g')"
				
				# get just the filename (without the path)
				file_basename="$(basename "$file")"
				
				# the local file corresponding to the file on the server
				local_file="$galaxy_dir/$file_basename"

				# if file exists on server but not here,
				# mark for download
				if [ ! -f "$local_file" ]; then
					>&2 echo "does not exist: $local_file from $file"
					echo "$file"
					continue
				fi
				
				# check if local file is outdated
				local_timestamp="$(stat --printf="%Y" "$local_file")"
				if [ "$local_timestamp" -lt "$timestamp" ]; then
					>&2 echo "outdated: $local_file older than $file"
					>&2 echo "    difference: $(( $timestamp - $local_timestamp )) seconds"
					echo "$file"
					continue
				fi
				
				# check if file sizes differ
				local_filesize="$(stat --printf="%s" "$local_file")"
				if [ "$local_filesize" -ne "$filesize" ]; then
					>&2 echo "file sizes differ: $local_file and $file"
					>&2 echo "    difference: $(( $filesize - $local_filesize)) bytes"
					echo "$file"
					continue
				fi
				
				>&2 echo "up to date: $local_file"
			done
		}
	done
} | {
	# this section creates a SFTP command from the file path
	while read -r file; do
		# sed strips the long/ directory from destination path, if present
		echo "get \"/net/phizo/data/d/AST-02/certain/$file\" \"$(echo "$file" | sed -e 's/long\///g')\""
	done
} > "$sftp_commands"

# and sftp downloads the files from the server, if there are any to update
[ -s "$sftp_commands" ] && sftp -R 256 -B 65536 gst131@ssh.ucolick.org < "$sftp_commands"

# delete temporary file
rm "$sftp_commands"

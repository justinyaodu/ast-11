#!/bin/bash

# initialization actions common to all scripts

ulimit -s unlimited

# define some functions

# echo to standard error, prepend script name
echo-debug() {
	>&2 echo "$0: $@"
}

# exit with error code if any of the files don't exist
# useful for input files
assert-exists() {
	while [ "$1" != "" ]; do
		if [ ! -f "$1" ]; then
			echo-debug "error: file does not exist: $1"
			exit 1
		fi
		shift
	done
}

# exit with error code if any of the files do exist
# useful for output files
assert-does-not-exist() {
	while [ "$1" != "" ]; do
		if [ -f "$1" ]; then
			echo-debug "error: file already exists: $1"
			exit 1
		fi
		shift
	done
}

# if a file already exists, remove it and print a warning
# useful for temporary files
remove-if-exists() {
	if [ -f "$1" ]; then
		echo-debug "warning: file already exists, removing: $1"
		rm "$1"
	fi
}

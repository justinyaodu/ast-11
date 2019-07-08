#!/bin/bash

# initialization actions common to all scripts

ulimit -s unlimited

# define some functions

# echo to standard error, prepend script name
echo_debug() {
	>&2 echo "$0: $@"
}

# echo_debug and exit with error code
abort() {
	echo_debug $@
	exit 1
}

# exit with error code if any of the files don't exist
# useful for input files
assert_exists() {
	while [ "$1" != "" ]; do
		[ -f "$1" ] || abort "error: file does not exist: $1"
		shift
	done
}

# exit with error code if any of the files do exist
# useful for output files
assert_does_not_exist() {
	while [ "$1" != "" ]; do
		[ ! -f "$1" ] || abort "error: file already exists: $1"
		shift
	done
}

# if files already exist, remove them and print a warning
# useful for temporary files
remove_if_exists() {
	while [ "$1" != "" ]; do
		if [ -f "$1" ]; then
			echo_debug "warning: file already exists, removing: $1"
			rm "$1"
		fi
		shift
	done
}

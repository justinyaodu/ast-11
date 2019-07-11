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
	[ $# -ne 0 ] || abort "assert_exists: no files specified"
	while [ "$1" != "" ]; do
		[ -f "$1" ] || abort "error: file does not exist: $1"
		shift
	done
}

# exit with error code if any of the files do exist
# useful for output files
assert_does_not_exist() {
	[ $# -ne 0 ] || abort "assert_does_not_exist: no files specified"
	while [ "$1" != "" ]; do
		[ ! -f "$1" ] || abort "error: file already exists: $1"
		shift
	done
}

# if files already exist, remove them and print a warning
# useful for temporary files
remove_if_exists() {
	[ $# -ne 0 ] || abort "remove_if_exists: no files specified"
	while [ "$1" != "" ]; do
		if [ -f "$1" ]; then
			echo_debug "warning: file already exists, removing: $1"
			rm "$1"
		fi
		shift
	done
}

# function which returns 0 if using isofit
using_isofit() {
	[ -f ".using-isofit" ]
}

# print error message if we suspect that the user has not activated the conda environment
[ -n "$(type -P cl)" ] || abort "conda environment is not activated"

# print message when script starts running
echo_debug "running"

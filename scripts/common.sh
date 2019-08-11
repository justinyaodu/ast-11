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
	echo_debug "$@"
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

assert_directory_exists() {
	[ $# -ne 0 ] || abort "assert_directory_exists: no files specified"
	while [ "$1" != "" ]; do
		[ -d "$1" ] || abort "error: directory does not exist: $1"
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

assert_successful() {
	"$@" || abort "fatal error, exiting"
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

# function which finds the galaxy name and filter from a filename
get_galaxy_and_filter() {
	basename "$1" | grep -o "VCC[0-9][0-9][0-9][0-9]_[ugriz]"
}

# returns a filename minus the extension, but retaining the directory path
strip_extension() {
	sed -e 's/\.[^.]*$//g' <<< "$1"
}

strip_trailing_slash() {
	echo "$(sed -e 's/\/$//g' <<< "$1")"
}

# run a command and log output to a file as well
run_and_log() {
	# first argument is the log file
	log_file="$1"
	remove_if_exists "$log_file"

	# remove the first argument from the argument list
	shift

	# run the provided command and arguments,
	# saving stdout and stderr to the log file
	{
		"$@" 2>&1
	} | tee "$log_file"

	# return the exit code of the command which was run
	return "${PIPESTATUS[0]}"
}

# check to see whether the DS9 XPA server is up
ds9_xpa_running() {
	xpaget xpans 2>/dev/null | grep -q 'ds9'
}

# print a fancy banner
print_banner() {
	>&2 echo
	>&2 echo "======== $@ ========"
	>&2 echo
}

# returns the best model-subtracted image corresponding to the input original image
get_best() {
	local best_file="$1.best"

	if [ -f "$best_file" ]; then
		cat "$best_file"
		return
	fi

	local modsub="$(sed -e 's/\.fits$/_modsub3.fits/g' <<< "$1")"
	[ -f "$modsub" ] || local modsub="$(sed -e 's/\.fits$/_modsub2.fits/g' <<< "$1")"
	[ -f "$modsub" ] || local modsub="$(sed -e 's/\.fits$/_modsub1.fits/g' <<< "$1")"
	[ -f "$modsub" ] || local modsub=""

	local rmf="$(sed -e 's/\.fits$/_rmf.fits/g' <<< "$1")"
	if [ -f "$rmf" ]; then
		if [ -z "$modsub" ]; then
			echo "$rmf"
		else
			echo_debug "no .best file: ambiguous between $modsub and $rmf"
			return 1
		fi
	else
		echo "$modsub"
		return
	fi
}

# print error message if we suspect that the user has not activated the conda environment
# do this by checking for the presence of the IRAF cl executable
[ -n "$(type -P cl)" ] || abort "conda environment is not activated"

# print message when script starts running
echo_debug "running"

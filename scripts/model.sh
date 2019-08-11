#!/bin/bash

# use bmodel/cmodel to generate an image from a galaxy light model

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <table.tab>"

table_file="$1"

# output image has the same name as the table file, but with a .fits extension
output_image="$(strip_extension "$table_file").fits"

log_file="$(strip_extension "$output_image")_model.log"

# abort if input file doesn't exist
assert_exists "$table_file"

# if output file exists, remove it
# it might be left over from a crashed cmodel run, so clean it up
remove_if_exists "$output_image"

# get background light value from table
background="$(./background.sh "$table_file")"

# function to run cmodel and kill it if it stops responding
safe_cmodel() {
	# log to file (can't use run_and_log because we also need to run in background)
	# start a subshell so that we can send a SIGQUIT to it to kill it if we need to
	# since cmodel seems to become completely unresponsive to anything else
	# (when run interactively, the only thing I've found that can kill a stuck
	# cmodel task is ctrl+backslash, which also kills the Bash script running it)
	./cmodel.cl "$table_file" "$output_image" "$background" "$1" 2>&1 | tee "$log_file" &
	local cl_pid="$!"

	# while cmodel.cl is still alive
	while kill -0 "$cl_pid" 2> /dev/null; do
		# make sure this loop doesn't run too often
		sleep 1

		# how long it's been since the log file was written to, in seconds
		age="$(($(date +'%s') - $(date +'%s' -r "$log_file")))"

		# if log file hasn't been modified in the last 15 seconds
		if [ "$age" -gt '15' ]; then
			# assume the process is completely stuck, and kill it
			model_pid="$(ps -o 'comm= pid=' | grep '^x_isophote.e' | grep -o '[0-9]*')"
			echo_debug "looks like modeling task (PID $model_pid) is stuck, killing"
			kill "$model_pid"
			break
		fi
	done
}

# create model, running appropriate cl script
safe_cmodel 'yes'

# if error encountered, try again but do not use higher harmonics
if grep -q "ERROR" "$log_file"; then
	remove_if_exists "$output_image"
	safe_cmodel 'no'
fi

# if an error still encountered, exit indicating failure
if grep -q "ERROR" "$log_file"; then exit 1; fi

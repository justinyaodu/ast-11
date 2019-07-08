#!/bin/bash

# use tprint to print a table

source common.sh

# print usage message if number of parameters is incorrect
if [ "$#" -ne 2 ]; then
	>&2 echo "usage: $0 <table.tab> <columns>"
	>&2 echo "  separate column names with commas"
	exit 1
fi

table_file="$1"
columns="$2"

# abort if input files don't exist
if [ ! -f "$table_file" ]; then
	>&2 echo "$0: error: input file does not exist"
	exit 1
fi

# perform subtraction
./tprint.cl "$table_file" "$columns"

#!/bin/bash

# use tprint to print a table

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 2 ] || abort "usage: $0 <table.tab> <comma,separated,column,names>"

table_file="$1"
columns="$2"

# abort if table doesn't exist
assert_exists "$table_file"

# print table
./tprint.cl "$table_file" "$columns"

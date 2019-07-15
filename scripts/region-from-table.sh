#!/bin/bash

# generate a DS9 region file showing the ellipses from an ISOFIT table

source common.sh

# function to print a line for one elliptical region
print_ellipse_line() {
	# ignore empty lines and comment lines
	if [ $# -ne 7 ] || [ "$1" == "#" ]; then return; fi

	row_num=$1
	x=$2
	y=$3
	ell=$4
	pa=$5
	smaj=$6
	intens=$7

	# calculate semi-minor axis from semi-major axis and ellipticity
	smin=$(bc -l <<< "$smaj * (1 - $ell)" | head -c 6)

	# convert position angle
	pa=$(bc -l <<< "90 + $pa" | head -c 6)

	# print region file line, replacing any INDEFs with zeroes
	line="ellipse($x,$y,$smaj,$smin,$pa) #text={$intens}"
	line="$(sed -e "s/INDEF/0/g" <<< "$line")"
	echo "$line"
}

# print usage message if number of parameters is incorrect
[ $# -eq 1 ] || abort "usage: $0 <table.tab>"

table_file="$1"
region_file="${table_file::-4}.reg"

assert_exists "$table_file"
assert_does_not_exist "$region_file"

# write beginning of region file
cat > "$region_file" <<- EOF
	# Region file format: DS9 version 4.1
	global color=green dashlist=8 3 width=1 font="helvetica 10 normal roman" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1
	image
EOF

# read table line by line
./tprint.sh "$table_file" "X0,Y0,ELLIP,PA,SMA,INTENS" |
{
	# use the data from each line to create a line describing one ellipse
	# and write it to the region file
	while read -r line; do
		print_ellipse_line $line >> "$region_file"
	done
}

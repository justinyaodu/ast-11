#!/bin/bash

# inserts arguments into geompar template

source common.sh

# print usage message if number of parameters is incorrect
[ $# -eq 7 ] || abort "usage: $0 <x0> <y0> <ellip0> <pa0> <sma0> <minsma> <maxsma>"

x0=$1
y0=$2
ellip0=$3
pa0=$4
sma0=$5
minsma=$6
maxsma=$7

# output to file, substituting variables in the correct locations
cat > uparmisegeompr.par << EOF
x0,r,h,$x0,1.,INDEF,"initial isophote center X"
y0,r,h,$y0,1.,INDEF,"initial isophote center Y"
ellip0,r,h,$ellip0,0.01,1.,"initial ellipticity"
pa0,r,h,$pa0,-90.,90.,"initial position angle (degrees)"
sma0,r,h,$sma0,5.,INDEF,"initial semi-major axis length"
minsma,r,h,$minsma,0.,INDEF,"minimum semi-major axis length"
maxsma,r,h,$maxsma,1.,INDEF,"maximum semi-major axis length"
step,r,h,0.1,0.001,INDEF,"sma step between successive ellipses"
linear,b,h,no,,,"linear sma step ?"
maxrit,r,h,INDEF,0.,INDEF,"maximum sma length for iterative mode"
recenter,b,h,yes,,,"allows finding routine to re-center x0-y0 ?"
xylearn,b,h,no,,,"updates pset with new x0-y0 ?"
physical,b,h,yes,,,"physical coordinate system ?"
mode,s,h,"al",,,
EOF

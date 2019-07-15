#!/bin/bash

# inserts arguments into controlpar template

source common.sh

[ $# -eq 1 ] || abort "usage: $0 <object locator threshold>"

ol_threshold=$1

cat > uparmisecontrr.par << EOF
conver,r,h,0.05,0.,,"convergency criterion (maximum harmonic amplitude)"
minit,i,h,10,1,INDEF,"minimun no. of iterations at each sma"
maxit,i,h,50,2,INDEF,"maximun no. of iterations at each sma"
hcenter,b,h,no,,,"hold center fixed ?"
hellip,b,h,no,,,"hold ellipticity fixed ?"
hpa,b,h,no,,,"hold position angle fixed ?"
wander,r,h,INDEF,0.,,"maximum wander in successive isophote centers"
maxgerr,r,h,0.5,0.,INDEF,"maximum acceptable gradient relative error"
olthresh,r,h,$ol_threshold,0.,INDEF,"object locator\'s k-sigma threshold"
soft,b,h,no,,,"soft stop ?"
mode,s,h,"al",,,
EOF

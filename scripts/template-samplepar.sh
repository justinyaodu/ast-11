#!/bin/bash

# inserts arguments into samplepar template

source common.sh

[ $# -eq 1 ] || abort "usage: $0 <harmonics>"

harmonics="$1"

cat > uparmisesamplr.par << EOF
integrmode,s,h,"bi-linear",bi-linear|mean|median,,"area integration mode"
usclip,r,h,3.,0.,INDEF,"sigma-clip criterion for upper deviant points"
lsclip,r,h,3.,0.,INDEF,"sigma-clip criterion for lower deviant points"
nclip,i,h,1,0,INDEF,"number of sigma-clip iterations"
fflag,r,h,0.8,0.,1.,"acceptable fraction of flagged data points "
sdevice,s,h,"none",|none|stdgraph|stdplot|stdvdm,,"graphics device for ploting intensity samples"
tsample,s,h,"none",,,"tables with intensity samples"
absangle,b,h,yes,,,"sample angles refer to image coord. system ? "
harmonics,s,h,"$harmonics",,,"optional harmonic numbers to fit"
mode,s,h,"al",,,
EOF

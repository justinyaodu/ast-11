#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f
 
# initialize the CL environment, similar to what login.cl does

logver = "IRAF V2.16 March 2012"

set	home		= "/home/irafuser/Documents/ast-11/scripts/"
set	imdir		= "/tmp/irafuser/"
set	cache		= "U_CACHEDIR"
set	uparm		= "home$uparm/"
set	userid		= "irafuser"

# strange errors occurred using "stty xgterm" in scripts
# see documentation for more info
stty xterm

set	imextn		= "oif:imh fxf:fits,fit fxb:fxb plf:pl qpf:qp stf:hhh,??h"

showtype = yes

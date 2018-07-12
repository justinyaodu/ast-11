#!/home/rishi/anaconda2/envs/iraf27/iraf/bin/cl.e -f

# Arguments: "backgr filename filemodtab filemodfits filemodsub"

logver = "IRAF V2.16 March 2012"
set	home		= "/home/rishi/Documents/iraf/"
set	imdir		= "/tmp/rishi/"
set	cache		= "U_CACHEDIR"
set	uparm		= "home$uparm/"
set	userid		= "rishi"
stty xgterm
set	imextn		= "oif:imh fxf:fits,fit fxb:fxb plf:pl qpf:qp stf:hhh,??h"
showtype = yes

stsdas
analysis
isophote

string bgr
string filename
string filemodtab
string filemodfits
string filemodsub
{
	print(args) | scanf("%s %s %s %s %s", bgr, filename, filemodtab, filemodfits, filemodsub)

	printf("cmodel (\"%s\",\"%s\", parent=\"\", fulltable=yes, minsma=1., maxsma=1.,backgr=%s, interp=\"spline\", highar=yes, verbose=no)", filemodtab, filemodfits, bgr) | cl()

	printf("imarith (\"%s\",\"-\", \"%s\", \"%s\", title=\"\", divzero=0.,hparams=\"\", pixtype=\"\", calctype=\"\", verbose=no, noact=no)", filename, filemodfits, filemodsub) | cl()

	logout
}

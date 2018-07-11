#!/home/rishi/anaconda2/envs/iraf27/iraf/bin/cl.e -f

# Arguments: "x0 y0 pa0 maxsma backgr filename filemodtab filemodfits filemodsub"

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

int i1
int i2
int i3
int i4
string f1
string st1
string st2
string st3
string st4
{
	
	print(args) | scanf("%i %i %i %i %s %s %s %s %s", i1, i2, i3, i4, f1, st1, st2, st3, st4)

	geompar.x0 = i1
	geompar.y0 = i2
	geompar.pa0 = i3
	geompar.maxsma = i4

	samplepar.harmoni = "2 3 4"

	printf("ellipse (\"%s\",\"%s\", dqf=\".c1h\", inellip=\"\", geompar=\"\", controlpar=\"\",samplepar=\"\", magpar=\"\", interactive=no, device=\"red\", icommands=\"\",gcommands=\"\", masksz=5, region=no, memory=yes, verbose=yes)", st1, st2) | cl()

	printf("cmodel (\"%s\",\"%s\", parent=\"\", fulltable=yes, minsma=1., maxsma=1.,backgr=%s, interp=\"spline\", highar=yes, verbose=no)", st2, st3, f1) | cl()

	printf("imarith (\"%s\",\"-\", \"%s\", \"%s\", title=\"\", divzero=0.,hparams=\"\", pixtype=\"\", calctype=\"\", verbose=no, noact=no)", st1, st3, st4) | cl()

	logout
}

#!/home/rishi/anaconda2/envs/iraf27/iraf/bin/cl.e -f

# Arguments: "x0 y0 pa0 maxsma filename filemodtab"

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

int x
int y
int pa
int maxsma
string filename
string filemodtab
{
	print(args) | scanf("%i %i %i %i %s %s", x, y, pa, maxsma, filename, filemodtab)

	geompar.x0 = x
	geompar.y0 = y
	geompar.pa0 = pa
	geompar.maxsma = maxsma

	samplepar.harmoni = "2 3 4"

	printf("ellipse (\"%s\",\"%s\", dqf=\".c1h\", inellip=\"\", geompar=\"\", controlpar=\"\",samplepar=\"\", magpar=\"\", interactive=no, device=\"red\", icommands=\"\",gcommands=\"\", masksz=5, region=no, memory=yes, verbose=yes)", filename, filemodtab) | cl()

	logout
}

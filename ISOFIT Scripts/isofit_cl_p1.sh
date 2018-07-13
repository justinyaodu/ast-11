#!/home/rishi/anaconda2/envs/iraf27/iraf/bin/cl.e -f

# Arguments: "filename filemodtab geomparfile"

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

string filename
string filemodtab
string geomparfile
{
	print(args) | scanf("%s %s %s", filename, filemodtab, geomparfile)

	printf("ellipse (\"%s\",\"%s\", dqf=\".c1h\", inellip=\"\", geompar=\"%s\", controlpar=\"\",samplepar=\"samplepar.par\", magpar=\"\", interactive=no, device=\"red\", icommands=\"\",gcommands=\"\", masksz=5, region=no, memory=yes, verbose=yes)", filename, filemodtab, geomparfile) | cl()

	logout
}

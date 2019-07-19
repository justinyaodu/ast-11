#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# uses cmodel to generate an image from an ISOFIT light model

# initialize environment
cl < init.cl

# initialize variables so user isn't prompted
string infile = ""
string outfile = ""
real background = 0
string highar = ""

# read variables from command line arguments
print(args) | scanf("%s %s %f %s", infile, outfile, background, highar)

# load package
stsdas
analysis.isophote

# create model
printf("cmodel(table=\"%s\", output=\"%s\", backgr=%f, highar=%s, verbose=yes, interp=\"spline\")", infile, outfile, background, highar) | cl

logout

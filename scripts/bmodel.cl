#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# uses bmodel to generate an image from an ISOFIT light model

# initialize environment
cl < init.cl

# initialize variables so user isn't prompted
string infile = ""
string outfile = ""
real background = 0

# read variables from command line arguments
print(args) | scanf("%s %s %f", infile, outfile, background)

# load package
stsdas
analysis.isophote

# create model
printf("bmodel(table=\"%s\", output=\"%s\", backgr=%f, highar=no, verbose=yes, interp=\"linear\")", infile, outfile, background) | cl

logout

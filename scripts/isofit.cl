#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# initialize environment 
cl < init.cl

# initialize variables so user isn't prompted
string imgfile = ""
string tablefile = ""
string geomparfile = ""

# read variables from command line arguments
print(args) | scanf("%s %s %s", imgfile, tablefile, geomparfile)

# load package
stsdas
analysis.isophote

# generate table
printf("ellipse(input=\"%s\", output=\"%s\", geompar=\"%s\", control=\"controlpar.par\", samplep=\"samplepar.par\")", imgfile, tablefile, geomparfile) | cl

logout

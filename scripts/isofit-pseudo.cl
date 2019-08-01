#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# use ISOFIT to generate a galaxy light model, but with an input table

# initialize environment 
cl < init.cl

# initialize variables so user isn't prompted
string imgfile = ""
string tablefile = ""
string prevtable = ""

# read variables from command line arguments
print(args) | scanf("%s %s %s", imgfile, tablefile, prevtable)

# load package
stsdas
analysis.isophote

# generate table
printf("ellipse(input=\"%s\", output=\"%s\", inellip=\"%s\")", imgfile, tablefile, prevtable) | cl

logout

#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# use Ellipse to generate a galaxy light model

# initialize environment 
cl < init.cl

# initialize variables so user isn't prompted
string imgfile = ""
string tablefile = ""

# read variables from command line arguments
print(args) | scanf("%s %s", imgfile, tablefile)

# load package
stsdas
analysis.isophote

# generate table
printf("ellipse(input=\"%s\", output=\"%s\")", imgfile, tablefile) | cl

logout

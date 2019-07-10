#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# uses imcopy to copy an image

# initialize environment
cl < init.cl

# initialize variables so user isn't prompted
string infile = ""
string outfile = ""

# read variables from command line arguments
print(args) | scanf("%s %s", infile, outfile)

# perform copy
printf("imcopy(input=\"%s\", output=\"%s\")", infile, outfile) | cl

logout

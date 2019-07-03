#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# initialize environment 
cl < init.cl

# initialize variables so user isn't prompted
string tablefile = ""
string dumpfile = ""

# read variables from command line arguments
print(args) | scanf("%s %s", tablefile, dumpfile)

# dump intensity data from table
printf("tdump(table=\"%s\", cdfile=\"\", pfile=\"\", datafil=\"%s\", columns=\"INTENS\")", tablefile, dumpfile) | cl

logout

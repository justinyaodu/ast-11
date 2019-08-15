#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# use tprint to print table data

# initialize variables so user isn't prompted
string tablefile = ""
string columns = ""

# read variables from command line arguments
print(args) | scanf("%s %s", tablefile, columns)

# print table
printf("tprint(table=\"%s\", pwidth=INDEF, showhdr=yes, showunits=yes, columns=\"%s\", rows=\"-\")", tablefile, columns) | cl

logout

#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# initialize environment 
cl < init.cl

# initialize variables so user isn't prompted
string infile1 = ""
string infile2 = ""
string outfile = ""

# read variables from command line arguments
print(args) | scanf("%s %s %s", infile1, infile2, outfile)

# perform subtraction of infile1 and infile2 and output to outfile
printf("imarith(operand1=\"%s\", op=\"-\", operand2=\"%s\", result=\"%s\")", infile1, infile2, outfile) | cl

logout

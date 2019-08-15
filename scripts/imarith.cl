#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# wrapper for imarith

# initialize variables so user isn't prompted
string infile1 = ""
string operator = ""
string infile2 = ""
string outfile = ""

# read variables from command line arguments
print(args) | scanf("%s %s %s %s", infile1, operator, infile2, outfile)

# perform subtraction of infile1 and infile2 and output to outfile
printf("imarith(operand1=\"%s\", op=\"%s\", operand2=\"%s\", result=\"%s\")", infile1, operator, infile2, outfile) | cl

logout

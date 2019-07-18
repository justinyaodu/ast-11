#!/home/irafuser/miniconda2/envs/iraf27/iraf/bin/cl.e -f

# crops an image using imcopy

# initialize environment
cl < init.cl

# initialize variables so user isn't prompted
string infile = ""
string outfile = ""
int x_crop = 0
int y_crop = 0

# read variables from command line arguments
print(args) | scanf("%s %s %d %d", infile, outfile, x_crop, y_crop)

# get image header, from which we can extract the image size information

string header = ""
imheader(infile) | scanf("%s", header)

# find positions of brackets and commas in string

int open_bracket_pos = 0
open_bracket_pos = stridx("[", header)

int comma_pos = 0
comma_pos = stridx(",", header)

int close_bracket_pos = 0
close_bracket_pos = stridx("]", header)

# initialize variables
int x_size = 0
int y_size = 0

# use substring to extract positions of each measurement
print(substr(header, open_bracket_pos + 1, comma_pos - 1)) | scanf("%d", x_size)
print(substr(header, comma_pos + 1, close_bracket_pos - 1)) | scanf("%d", y_size)

# find maximum values (size minus amount to crop)
# (image coordinates are 1-indexed)

int x_max = 0
x_max = x_size - x_crop

int y_max = 0
y_max = y_size - y_crop

# minimum values are simply 1 plus the amount to crop

int x_min = 0
x_min = 1 + x_crop

int y_min = 0
y_min = 1 + y_crop

# crop
printf("imcopy(input=\"%s[%d:%d,%d:%d]\", output=\"%s\")", infile, x_min, x_max, y_min, y_max, outfile) | cl

logout

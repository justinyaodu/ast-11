from astropy.io import fits

# find the center of a FITS image
def fits_center(fits):
    x0, y0 = fits_size(fits)
    x0 /= 2
    y0 /= 2
    return x0, y0

def fits_size(fits):
    try:
        width = int((fits[0].header[3]))
        height = int((fits[0].header[4]))
    except ValueError:
        width = len(fits[0].data)
        height = len(fits[0].data[0])
    return width, height

# print the center of a FITS image
def get_fits_center(filename):
    x0, y0 = fits_center(fits.open(filename))
    print(str(x0) + " " + str(y0))

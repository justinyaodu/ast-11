from astropy.io import fits

# find the center of a FITS image
def fits_center(fits)
    x0 = int((fits[0].header[3])/2)
    y0 = int((fits[0].header[4])/2)
    return x0, y0

# print the center of a FITS image
def get_fits_center(filename):
    x0, y0 = fits_center(fits.open(filename))
    print(str(x0) + " " + str(y0))

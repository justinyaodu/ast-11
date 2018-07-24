from astropy.io import fits

def getFitsInfo(filename):
    file = fits.open(filename)
    x0 = int((file[0].header[3])/2)
    y0 = int((file[0].header[4])/2)
    print(str(x0) + " " + str(y0))

from astropy.io import fits
from astropy import wcs as pywcs
import math

def arcsec_to_px(image):
    # get image world coordinate system
    image_wcs = pywcs.WCS(fits.getheader(image))
    
    # experimentally printing many values from points across the image
    # gave results that agreed to about the fourth significant figure
    # this will work for images wider than 100px in both dimensions
    print pixels_per_arcsec_trial(image_wcs, 0, 0, 100, 100)

# calculate ratio of pixels per arcsecond using two points on the image
def pixels_per_arcsec_trial(image_wcs, x1, y1, x2, y2):
    # get WCS coordinates
    ra1_deg, dec1_deg = image_wcs.wcs_pix2world(x1, y1, 0);
    ra2_deg, dec2_deg = image_wcs.wcs_pix2world(x2, y2, 0);

    # get angular differences in degrees
    delta_ra_deg = ra2_deg - ra1_deg;
    delta_dec_deg = dec2_deg - dec1_deg;

    # convert to radians
    delta_ra_rad = delta_ra_deg * math.pi / 180
    delta_dec_rad = delta_dec_deg * math.pi / 180

    # get angular distance
    delta_angle_rad = angular_distance(delta_ra_rad, delta_dec_rad)

    # convert to arcseconds
    delta_angle_arcsec = delta_angle_rad * 180 / math.pi * 3600

    # find pixel distance
    pixel_distance = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))

    # return conversion factor as pixels per arcsecond
    return pixel_distance / delta_angle_arcsec

# computes angular distance
# given a difference in right ascension and declination
def angular_distance(delta_ra, delta_dec):
    return math.sqrt(math.pow(delta_ra * math.cos(delta_dec), 2) + math.pow(delta_dec, 2))

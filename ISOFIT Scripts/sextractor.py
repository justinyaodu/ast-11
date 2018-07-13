import sewpy
import pyraf
from pyraf import iraf

def sourceExtract(galaxyname):
	sew = sewpy.SEW(params=["NUMBER"],
	config= {"DETECT_MINAREA": 50, "DETECT_THRESH": 3.0,
	"CHECKIMAGE_NAME": galaxyname + "_seg.fits", "CHECKIMAGE_TYPE": "SEGMENTATION",
	"WEIGHT_TYPE": "MAP_RMS", "WEIGHT_IMAGE": galaxyname + "_sig.fits"})
	sew(galaxyname + "_modsub.fits")
	iraf.imcopy(galaxyname + "_seg.fits", galaxyname + ".fits.pl")

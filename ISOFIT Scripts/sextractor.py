import sewpy
import pyraf
from pyraf import iraf

def sourceExtract(galaxyname):
	sew = sewpy.SEW(params=["NUMBER"],
	config= {"DETECT_MINAREA": 2, "DETECT_MAXAREA": 700, "DETECT_THRESH": 3,
	 "ANALYSIS_THRESH": 5.0, "DEBLEND_MINCOUNT": 0.002, "CHECKIMAGE_NAME": galaxyname + "_seg.fits",
	 "CATALOG_NAME": galaxyname + "_modsub.cat", "CHECKIMAGE_TYPE": "SEGMENTATION"})
	sew(galaxyname + "_modsub.fits")
	iraf.imcopy(galaxyname + "_seg.fits", filename + ".pl")

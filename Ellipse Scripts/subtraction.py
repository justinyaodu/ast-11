

import pyraf
from pyraf import iraf
import sewpy
from astropy.io import fits
import sys


if __name__ == "__main__":
    
    if (len(sys.argv) == 4):
        
        filename = sys.argv[1]
        galaxyname = filename[:-5]
        sma = sys.argv[2]
        background = sys.argv[3]
        file = fits.open(filename)
        x0 = (file[0].header[3])/2
        y0 = (file[0].header[4])/2

        iraf.stsdas()
        iraf.analysis()
        iraf.isophote()

        pyraf.iraftask.gettask("geompar")[0].setParam("x0", x0)
        
        pyraf.iraftask.gettask("geompar")[0].setParam("y0", y0)
        
        pyraf.iraftask.gettask("geompar")[0].setParam("maxsma", sma)

        iraf.ellipse(filename, galaxyname + ".tab")
        
        iraf.bmodel(galaxyname + ".tab", galaxyname + "_mod.fits", backgr=background)
        iraf.imarith(operand1=filename, op="-", operand2=galaxyname + "_mod.fits", result=galaxyname+"_modsub.fits")

        sew = sewpy.SEW(params=["NUMBER"], 
                                config= {"DETECT_MINAREA": 2, "DETECT_MAXAREA": 700, "DETECT_THRESH": 3, "ANALYSIS_THRESH": 5.0, "DEBLEND_MINCOUNT": 0.002, 
                                			"CHECKIMAGE_NAME": galaxyname + "_seg.fits", "CATALOG_NAME": galaxyname + "_modsub.cat", "CHECKIMAGE_TYPE": "SEGMENTATION"})
        
        sew(galaxyname + "_modsub.fits")

        iraf.imcopy(galaxyname + "_seg.fits", filename + ".pl")

        iraf.ellipse(filename,galaxyname + "_SEx.tab")
        
        iraf.bmodel(galaxyname + "_SEx.tab", galaxyname + "_modSEx.fits", backgr=background)
        iraf.imarith(operand1=filename, op="-", operand2=galaxyname + "_modSEx.fits", result=galaxyname+"_modsubSEx.fits")
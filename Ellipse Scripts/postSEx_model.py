import sys
import sewpy
import pyraf
from pyraf import iraf

if __name__ == "__main__":
    if (not (len(sys.argv) == 6)):
        print("Usage: python postSEx_model.py <input filename> <center x> <center y> <max sma> <backgd>")
    else:
        #Read command line inputs
        filename = sys.argv[1]
        galaxy_name = filename[:-5]
        center_x = sys.argv[2]
        center_y = sys.argv[3]
        sma = sys.argv[4]
        bg = sys.argv[5]

        #Load isophote tasks (ellipse, bmodel, geompar)
        iraf.stsdas()
        iraf.analysis()
        iraf.isophote()

        iraf.imcopy(galaxy_name + "_seg.fits", filename + ".pl")

        iraf.ellipse(filename,galaxy_name + "_SEx.tab")
        iraf.bmodel(galaxy_name + "_SEx.tab", galaxy_name + "_mod_SEx.fits", backgr=bg)
        iraf.imarith(operand1=filename, op="-", operand2=galaxy_name + "_mod_SEx.fits", result=galaxy_name+"_modsub_SEx.fits")

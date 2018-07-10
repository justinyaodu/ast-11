import sys
import sewpy
import pyraf
from pyraf import iraf

if __name__ == "__main__":
    if (not (len(sys.argv) == 6 or len(sys.argv) == 7)):
        print("Usage: python ellipse_model.py <input filename> <center x> <center y> <max sma> <backgd> [SE iters]")
    else:
        #Read command line inputs
        filename = sys.argv[1]
        galaxy_name = filename[:-5]
        center_x = sys.argv[2]
        center_y = sys.argv[3]
        sma = sys.argv[4]
        bg = sys.argv[5]
        se_iters = 1 if len(sys.argv) == 6 else sys.argv[6]

        #Load isophote tasks (ellipse, bmodel, geompar)
        iraf.stsdas()
        iraf.analysis()
        iraf.isophote()

        #Configure geompar
        pyraf.iraftask.gettask("geompar")[0].setParam("x0", center_x)
        pyraf.iraftask.gettask("geompar")[0].setParam("y0", center_y)
        pyraf.iraftask.gettask("geompar")[0].setParam("maxsma", sma)


        iraf.ellipse(filename,galaxy_name + ".tab")
        iraf.bmodel(galaxy_name + ".tab", galaxy_name + "_mod.fits", backgr=bg)
        iraf.imarith(operand1=filename, op="-", operand2=galaxy_name + "_mod.fits", result=galaxy_name+"_modsub.fits")

        for i in range(se_iters): #TODO
            sew = sewpy.SEW(params=["NUMBER"],
            config={"DETECT_MINAREA": 150, "DETECT_THRESH": 3, "CHECKIMAGE_NAME": galaxy_name + "_seg.fits",
             "CATALOG_NAME": galaxy_name + "_modsub.cat", "CHECKIMAGE_TYPE": "SEGMENTATION"})
            sew(galaxy_name + "_modsub.fits")

            iraf.imcopy(galaxy_name + "_seg.fits", filename + ".pl")

            iraf.ellipse(filename,galaxy_name + "_SEx.tab")
            iraf.bmodel(galaxy_name + "_SEx.tab", galaxy_name + "_mod_SEx.fits", backgr=bg)
            iraf.imarith(operand1=filename, op="-", operand2=galaxy_name + "_mod_SEx.fits", result=galaxy_name+"_modsub_SEx.fits")

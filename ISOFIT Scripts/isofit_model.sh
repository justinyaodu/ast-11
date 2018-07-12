if [ "$#" -ne 1 ]; then
    echo "Usage: ./isofit_model.sh <GAL_NAME>"
fi

filename=$1".fits"
modtab=$1"_mod.tab"
modfits=$1"_mod.fits"
modsubfits=$1"_modsub.fits"

fitsdump=$(python -c "import fits_center; fits_center.getFitsInfo(\"$filename\")")
fitsarr=($fitsdump)
x0=${fitsarr[0]}
y0=${fitsarr[1]}
maxsma=${fitsarr[2]}

posangle=$(python -c "import posAngle; posAngle.getPosAng(\"$1\", \"gal_list.cat\")")

./isofit_cl_p1.sh $x0 $y0 $posangle $maxsma $filename $modtab

bgdump=$(python -c "import background; background.getBgrd(\"$modtab\")")
bgarr=($bgdump)
bg=${bgarr[${#bgarr[@]}-1]}

./isofit_cl_p2.sh $bg $filename $modtab $modfits $modsubfits


#... call isofit_cl.sh
#... call Source Extractor
#... call isofit_cl.sh again with SE results
#... remove intermediary files

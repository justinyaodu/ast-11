if [ "$#" -ne 4 ]; then
    echo "Usage: ./isofit_model.sh <GAL_NAME> <MAX_SMA> <BGR> <PA0>"
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

posangle=$(python -c "import posAngle; posAngle.getPosAng(\"$galname\", \"$filter\", \"gal_list.cat\")") #FIX

bgdump=$(python -c "import background; background.getBgrd(\"$modtab\")")
bgarr=($bgdump)
bg-${bgarr[${#bgarr[@]}-1]}


#... call isofit_cl.sh
#... call Source Extractor
#... call isofit_cl.sh again with SE results
#... remove intermediary files

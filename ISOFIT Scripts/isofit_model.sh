#Written to run on Linux IRAF with ISOFIT installed (Ubuntu)

if [ "$#" -ne 1 ]; then
    echo "Usage: ./isofit_model.sh <GAL_NAME>"
fi

ulimit -s unlimited

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

geomparfile=$filename"_geompar.par"

python -c "import generate_paramfiles; generate_paramfiles.gen_geompar(\"$geomparfile\",x0=$x0,y0=$y0,maxsma=$maxsma,pa0=$posangle)"

./isofit_cl_p1.sh $filename $modtab $geomparfile

bgdump=$(python -c "import background; background.getBgrd(\"$modtab\")")
bgarr=($bgdump)
bg=${bgarr[${#bgarr[@]}-1]}

./isofit_cl_p2.sh $bg $filename $modtab $modfits $modsubfits

python -c "import sextractor; sextractor.sourceExtract(\"$1\")"

modtab=$1"_mod_SEx.tab"
modfits=$1"_mod_SEx.fits"
modsubfits=$1"_modsub_SEx.fits"

./isofit_cl_p1.sh $filename $modtab $geomparfile

bgdump=$(python -c "import background; background.getBgrd(\"$modtab\")")
bgarr=($bgdump)
bg=${bgarr[${#bgarr[@]}-1]}

./isofit_cl_p2.sh $bg $filename $modtab $modfits $modsubfits

remove=true
if [ "$remove" = true ] ; then
    mv $modsubfits modeled_$filename
    mv $1"_modsub.fits" modeled_noSEx_$filename
    rm $filename".pl"
    rm $1_*
fi

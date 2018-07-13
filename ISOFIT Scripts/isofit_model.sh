#Written to run on Linux IRAF with ISOFIT installed (Ubuntu)

if [ "$#" -ne 1 ] && [ "$#" -ne 2 ]; then
    echo "Usage: ./isofit_model.sh <GAL_NAME> [keep/remove]"
    exit 1
fi

remove=false
if [ "$#" -ne 1 ]; then
    if [ "$2" = "keep" ];
    then
      remove=false
    else
      if [ "$2" = "remove" ];
      then
        remove=true
      else
        echo "Usage: ./isofit_model.sh <GAL_NAME> [keep/remove]"
        exit 1
      fi
    fi
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

geomparfile=$1"_geompar.par"

python -c "import generate_paramfiles; generate_paramfiles.gen_geompar(\"$geomparfile\",x0=$x0,y0=$y0,maxsma=$maxsma,pa0=$posangle)"

./isofit_cl_p1.sh $filename $modtab $geomparfile

bgdump=$(python -c "import background; background.getBgrd(\"$modtab\")")
bgarr=($bgdump)
bg=${bgarr[${#bgarr[@]}-1]}

./isofit_cl_p2.sh $bg $filename $modtab $modfits $modsubfits

python -c "import sextractor; sextractor.sourceExtract(\"$1\")"

modtabsex=$1"_mod_SEx.tab"
modfitssex=$1"_mod_SEx.fits"
modsubfitssex=$1"_modsub_SEx.fits"

./isofit_cl_p1.sh $filename $modtabsex $geomparfile

bgdump=$(python -c "import background; background.getBgrd(\"$modtabsex\")")
bgarr=($bgdump)
bg=${bgarr[${#bgarr[@]}-1]}

./isofit_cl_p2.sh $bg $filename $modtabsex $modfitssex $modsubfitssex

if [ "$remove" = true ] ; then
  rm $modtab
  rm $modfits
  rm $filename".pl"
  rm $1"_seg.fits"
  rm $modtabsex
  rm $modfitssex
  rm $geomparfile
fi

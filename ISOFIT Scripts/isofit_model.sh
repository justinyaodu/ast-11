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

# get x and y coordinates of galaxy center in image
# galaxies are centered, so this is simply the center of the image
fitsdump=$(python -c "import fits_center; fits_center.getFitsInfo(\"$filename\")")
fitsarr=($fitsdump)
x0=${fitsarr[0]}
y0=${fitsarr[1]}

# read position angle and max semi-major axis from galaxy catalog
posangle=$(python -c "import read_catalog; read_catalog.getPosAng(\"$1\", \"gal_list.cat\")")
maxsma=$(python -c "import read_catalog; read_catalog.getSMA(\"$1\", \"gal_list.cat\")")

# generate geompar file for this galaxy
geomparfile=$1"_geompar.par"
python -c "import generate_paramfiles; generate_paramfiles.gen_geompar(\"$geomparfile\",x0=$x0,y0=$y0,maxsma=$maxsma,pa0=$posangle)"

# generate galaxy light model
./isofit_cl_p1.sh $filename $modtab $geomparfile

# get background value
# TODO figure out how the background value is obtained for the first pass
bgdump=$(python -c "import background; background.getBgrd(\"$modtab\")")
bgarr=($bgdump)
bg=${bgarr[${#bgarr[@]}-1]}

# generate image galaxy light model and perform subtraction
./isofit_cl_p2.sh $bg $filename $modtab $modfits $modsubfits

# create mask for bright objects
python -c "import sextractor; sextractor.sourceExtract(\"$1\")"

modtabsex=$1"_mod_SEx.tab"
modfitssex=$1"_mod_SEx.fits"
modsubfitssex=$1"_modsub_SEx.fits"

# generate galaxy light model, using the mask this time
./isofit_cl_p1.sh $filename $modtabsex $geomparfile

# find background value
bgdump=$(python -c "import background; background.getBgrd(\"$modtabsex\")")
bgarr=($bgdump)

# gets last element in array
# TODO doesn't background.py already do this?
bg=${bgarr[${#bgarr[@]}-1]}

# generate image from model and subtract again
./isofit_cl_p2.sh $bg $filename $modtabsex $modfitssex $modsubfitssex

# clean up files
if [ "$remove" = true ] ; then
  rm $modtab
  rm $modfits
  rm $filename".pl"
  rm $1"_seg.fits"
  rm $modtabsex
  rm $modfitssex
  rm $geomparfile
fi

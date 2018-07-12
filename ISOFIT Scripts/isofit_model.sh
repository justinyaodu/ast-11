if [ "$#" -ne 4 ]; then
    echo "Usage: ./isofit_model.sh <GAL_NAME> <MAX_SMA> <BGR> <PA0>"
fi
galname = "$(echo $1 | cut-d'_' -f1)"
filter = "$(echo $1 | cut-d'_' -f2)"
filename=$1".fits"
modtab=$1"_mod.tab"
modfits=$1"_mod.fits"
modsubfits=$1"_modsub.fits"

bgdump=$(python -c "import background; background.getBgrd(\"$modtab\")")
bgarr=($bgdump)
bg-${bgarr[${#bgarr[@]}-1]}

posangle = $(python -c "import posAngle; posAngle.getPosAng(\"$galname\", \"$filter\", \"gal_list.cat\")")

#TODO argument setup:
#CALCULATE CENTER
#SET VAL FOR MAX_SMA
#LOOK UP PA0


#... call isofit_cl.sh
#... call Source Extractor
#... call isofit_cl.sh again with SE results
#... remove intermediary files

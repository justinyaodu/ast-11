if [ "$#" -ne 4 ]; then
    echo "Usage: ./isofit_model.sh <GAL_NAME> <MAX_SMA> <BGR> <PA0>"
fi

filename=$1".fits"
modtab=$1"_mod.tab"
modfits=$1"_mod.fits"
modsubfits=$1"_modsub.fits"


#TODO argument setup:
#CALCULATE CENTER
#SET VAL FOR MAX_SMA
#LOOK UP PA0
#EXTRACT BGR


#... call isofit_cl.sh
#... call Source Extractor
#... call isofit_cl.sh again with SE results
#... remove intermediary files

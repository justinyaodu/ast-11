if [ "$#" -ne 4 ]; then
    echo "Usage: ./isofit_model.sh <GAL_NAME> <MAX_SMA> <BGR> <PA0>"
fi

filename=$(python -c "import arg_extract; arg_extract.origFits(\"$1\")")
modtab=$(python -c "import arg_extract; arg_extract.modTab(\"$1\")")
modfits=$(python -c "import arg_extract; arg_extract.modFits(\"$1\")")
modsubfits=$(python -c "import arg_extract; arg_extract.modsubFits(\"$1\")")


#TODO argument setup:
#CALCULATE CENTER
#SET VAL FOR MAX_SMA
#LOOK UP PA0
#EXTRACT BGR


#... call isofit_cl.sh
#... call Source Extractor
#... call isofit_cl.sh again with SE results
#... remove intermediary files

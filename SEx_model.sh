python preSEx_model.py $1 $2 $3 $4 $5
GALAXY=$(echo $1| cut -d'.' -f 1)
G=$"_g"
DETEC=$(echo $1| cut -d'_' -f 1)
DETECT=$DETEC$G
ADDA='_modsub.fits'
ADDB='_modsub.cat'
ADDC='_seg.fits'
ADDD='.fits'
ADDE='_sig.fits'
TEXT='sex '$DETECT$ADDA','$GALAXY$ADDA' -c ngvs.sex -WEIGHT_IMAGE '$DETECT$ADDE','$GALAXY$ADDE
echo $TEXT
#python postSEx_model.py $1 $2 $3 $4 $5

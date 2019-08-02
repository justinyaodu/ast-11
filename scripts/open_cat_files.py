import astropy
from astropy.io import fits
import sys
import numpy

def read_catalog(catalog_file_name):
  x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,p_gc=([] for i in range(15))
  arr=[x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,p_gc]
  hdul=fits.open(catalog_file_name)
  data=hdul[1].data
  arr_indexes=[0,1,2,3,5,6,7,8,9,11,12,13,14,15,28]
  index=0
  for x in range(1,166):
	sep_data=data[x]
	for y in arr_indexes:
		current_arr=arr[index]
		current_arr[index]=sep_data[y]
		index=index+1
  for x in range(31):
	print x_sex[x] + " " + y_sex[x] + " " + ra[x] + " " + dec[x] + " " + umag[x] + " " + gmag[x] + " " + rmag[x]  + " " + imag[x]  + " " + zmag[x] + " " + umagerr[x] + " " + gmagerr[x] + " " + rmagerr[x] + " " + imagerr[x] + " " + zmagerr[x] + " " + p_gc[x]
  #hdul.info()
  sys.exit(0)

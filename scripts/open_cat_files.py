
import astropy
from astropy.io import fits
import sys
import numpy

def read_catalog(catalog_file_name):
  ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,p_gc=([] for i in range(13))
  hdul=fits.open(catalog_file_name)
  data=hdul[1].data
  for x in range(31):
	sep_data=data[x]
	ra.append(sep_data[2])
  #hdul.info()
  print(ra)
  sys.exit(0)

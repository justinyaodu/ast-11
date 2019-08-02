
import astropy
from astropy.io import fits
import sys
import numpy

def read_catalog(catalog_file_name):
  hdul=fits.open(catalog_file_name)
  data=hdul[1].data
  arr=numpy.zeros(30,30) 
  for x in range(30):
	for y in range(30):
		seperate_data=data[y]
		arr[x][y]=seperate_data[y]
  hdul.info()
  print(arr[0])
  sys.exit(0)

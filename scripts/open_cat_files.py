
import astropy
from astropy.io import fits
import sys

def read_catalog(catalog_file_name):
  hdul=fits.open(catalog_file_name)
  data=hdul[1].data
  print(data)
  sys.exit(0)

#!/bin/bash

from astropy.io import fits
import sys

def read_catalog():
  catalog_file=astropy.io.fits.open()
  hdul=fits.open(catalog_file)
  data=hdul[1].data
  data.info()
sys.exit(0)

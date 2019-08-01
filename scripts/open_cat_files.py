#!/bin/bash

from astropy.io import fits

source common.sh

def read_catalog():
  catalog_file=astropy.io.fits.open()
  hdul=fits.open(catalog_file)
sys.exit(0)

import sys
import re
import numpy as np
import fits_center

  #DOCUMENTATION
def count_original_pixel(mask_image):
  row_num,x_cor,y_cor,ellipticity,pos_ang,sma = np.loadtxt(sys.stdin, unpack=True)
  
  #check for the INDEF replaced value of -10000 and replace with reasonable values to check
  x0,y0 = fits_center.fits_center(mask_image)
  x_cor[x_cor == -10000] = x0
  y_cor[y_cor == -10000] = y0
  ellipticity[ellipticity == -10000] = 0
  pos_ang[pos_ang == -10000] = 0
  
  #using the isophotes
  #index is the index to go through each array value
  #count is to count how many of the isophotes pass the test (if enough don't pass, then the mask = bad)
  index=0
  count=0
  while(index < len(x_cor)):
    
    
  
  
  
  #0=masked, not 0 = not masked
  

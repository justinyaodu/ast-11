import sys
import re
import numpy as np
import fits_center

  #check to see how much of the isophote is masked
def check_masking(mask_image):
  row_num,x_cor,y_cor,ellipticity,pos_ang,sma = np.loadtxt(sys.stdin, unpack=True)
  
  #check for the INDEF replaced value of -10000 and replace with reasonable values to check
  x0,y0 = fits_center.fits_center(mask_image)
  x_cor[x_cor == -10000] = x0
  y_cor[y_cor == -10000] = y0
  ellipticity[ellipticity == -10000] = 0
  pos_ang[pos_ang == -10000] = 0
  
  #using the isophotes to get the percentage of masked/total
  #index is the index to go through each array value
  #countMasked is to count how many pixels in ellipse are masked
  #count is to count how many of the isophotes pass the test (if enough don't pass, then the mask = bad)
  #countEllipse is to count the number of pixels being tested
  index=0
  countMasked=0
  count=0
  countEllipse=0
  height,width = fits_center.fits_size(mask_image)
  while index < len(x_cor):
    for x in range(0,height):
      for y in range(0,width):
        if point_in_ellipse(x_cor[index],y_cor[index],ellipticity[index],pos_ang[index],sma[index],x,y):
          countEllipse += 1
          if data[y,x]!=0:
              countMasked += 1
    if countMasked/countEllipse <= 0.4:      
      count += 1
    index += 1 
  percentage = count/len(x_cor) 
  if percentage > 0.7: 
    sys.exit(0)
  else:
    sys.exit(1)
                  
  #test to see if the tested point is in the isophote ellipse                   
def point_in_ellipse(x0, y0, ell, pa, smaj, x, y):
    # calculate semi-minor axis length
    smin = smaj * (1 - ell)

    # translate everything so that ellipse is centered at the origin
    x -= x0
    y -= y0

    # convert position angle to rotation CCW from x-axis
    angle = 90 + pa

    # check whether point is in rotated ellipse
    return (math.pow(x * math.cos(angle) + y * math.sin(angle), 2) / math.pow(smaj, 2)
          + math.pow(x * math.sin(angle) - y * math.cos(angle), 2) / math.pow(smin, 2)) < 1

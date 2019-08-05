#code to output a table similar to that of Sextractor's catalog table
#outputs a table form the catalog fits file found from photcat_indv (Raja's server)

import astropy
from astropy.io import fits
import sys
import numpy as np

def open_catalog(catalog_file_namesextractor_catalog):
  	
  x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,p_gc=([] for i in range(15))
  arr=[x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,p_gc]
  hdul=fits.open(catalog_file_name)
  data=hdul[1].data
  arr_indexes=[0,1,2,3,5,6,7,8,9,11,12,13,14,15,28]
  index=0
  for x in range(0,165):
	sep_data=data[x]
	for y in arr_indexes:
		current_arr=arr[index]
		current_arr.append(sep_data[y])
		index=index+1
	index=0
  number=0
  for x in range(31):
	print (str(number) + "      " + str(x_sex[x]) + "  " + str(y_sex[x]) + "  " + str(ra[x]) + "  " + str(dec[x]) + "  " + str(umag[x]) + "  " + str(gmag[x]) + "  " + str(rmag[x])  + "  " + str(imag[x])  + "  " + str(zmag[x]) + "  " + str(umagerr[x]) + "  " + str(gmagerr[x]) + "  " + str(rmagerr[x]) + "  " + str(imagerr[x]) + "  " + str(zmagerr[x]) + "  " + str(p_gc[x]))
	print ("\n")
	number=number+1
  #opening the sextractor catalog	
  s_nmb,s_x_image,s_y_image,s_alpha,s_delta,s_a_world,s_erra_world,s_b_world,s_errb_world,s_theta_pa,s_errtheta_pa,s_elongation,s_ellip,s_mag_auto,s_magerr_auto,s_mag_best,s_magerr_best,s_mag_iso,s_magerr_iso,s_mag_isocor,s_magerr_isocor,s_mag_petro,s_magerr_petro,s_mag_aper,magerr_aper,s_flux_rad,s_kron_rad,s_petro_rad,s_mu_max,s_background,s_isoarea_image,s_fwhm_image,s_flags,s_class_star=np.loadtxt(sextractor_catalog,unpack=True)
  #hdul.info()
  sys.exit(0)

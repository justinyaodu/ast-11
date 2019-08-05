#code to open the catalogs from sextractor and catalog fits file and then put them into 
#arrays as seperate objects with the sorted out variables

import astropy
from astropy.io import fits
import sys
import numpy as np

class SextractorObj:
	def __init__(self,ra,dec,magnitude):
		self.ra=ra
		self.dec=dec
		self.magnitude=magnitude
class FitsObj:
	def __init__(self,ra,dec,mag):
		self.ra=ra
		self.dec=dec
		self.mag=mag

def open_catalog(catalog_file_name,sextractor_catalog):
	x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,p_gc=([] for i in range(15))
	arr=[x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,p_gc]
	hdul=fits.open(catalog_file_name)
	data=hdul[1].data
	arr_indexes=[0,1,2,3,5,6,7,8,9,11,12,13,14,15,28]
	index=0
	for x in len(x_sex):
		sep_data=data[x]
		for y in arr_indexes:
			current_arr=arr[index]
			current_arr.append(sep_data[y])
			index=index+1
		index=0
	#opening the sextractor catalog	
	s_nmb,s_x_image,s_y_image,s_alpha,s_delta,s_a_world,s_erra_world,s_b_world,s_errb_world,s_theta_pa,s_errtheta_pa,s_elongation,s_ellip,s_mag_auto,s_magerr_auto,s_mag_best,s_magerr_best,s_mag_iso,s_magerr_iso,s_mag_isocor,s_magerr_isocor,s_mag_petro,s_magerr_petro,s_mag_aper,magerr_aper,s_flux_rad,s_kron_rad,s_petro_rad,s_mu_max,s_background,s_isoarea_image,s_fwhm_image,s_flags,s_class_star=np.loadtxt(sextractor_catalog,unpack=True)
	
	#making the objects
	band_name=sextractor_catalog[8]
	sex_obj=[]
	fits_obj=[]
	fits_index=0
	sex_index=0
	test_mags=[]
	if band_name=="u":
		test_mags=umag
	elif band_name=="g":
		test_mags=gmag
	elif band_name=="r":
		test_mags=rmag
	elif band_name=="i":
		test_mags=imag
	elif band_name=="z":
		test_mags=zmag
		
	for fits_index in len(x_sex):
		fits_obj.append(FitsObj(ra[fits_index],dec[fits_index],test_mags[fits_index])
				
	for sex_index in len(s_x_image):
		#CHANGE THE MAG_ISO VARIABLE WHEN YOUKYUNG TELLS YOU WHICH MAGNITUDE TO USE
		sex_obj.append(SextractorObj(s_alpha[sex_index],s_delta[sex_index],s_mag_iso[sex_index])
	print(fits_obj,sex_obj)			       

#code to open the catalogs from sextractor and catalog fits file and then put them into 
#arrays as seperate objects with the sorted out variables

import astropy
from astropy.io import fits
import sys
import numpy as np
import math

class SextractorObj:
	def __init__(self,ra,dec,magnitude):
		self.ra=ra
		self.dec=dec
		self.magnitude=magnitude
	def __str__(self):
		return "SEXTRACTOR = ra: "+str(self.ra)+ "   dec: " + str(self.dec)+"   magnitude: "+str(self.magnitude)
class FitsObj:
	def __init__(self,ra,dec,mag):
		self.ra=ra
		self.dec=dec
		self.mag=mag
	def __str__(self):
		return "FITS = ra: "+str(self.ra)+ "   dec: " + str(self.dec)+"   magnitude: " +str(self.mag)
class Match:
	def __init__(self,sex_object,fits_object):
		self.sex_object=sex_object
		self.fits_object=fits_object
	def __str__(self):
		return "MATCHED OBJECT = FITS ra: "+str(fits_object.ra)+ "   dec: " + str(fits_object.dec)+"   magnitude: " +str(fits_object.mag)+"\n"+ "SEXTRACTOR ra: "+str(sex_object.ra)+ "   dec: " + str(sex_object.dec)+"   magnitude: " +str(sex_object.mag)		
		
	
	
	
#finding the distance between the sextractor and fits catalog to find the perfect match
def distance (s_ra,f_ra,s_dec,f_dec):
	rad_f_ra=f_ra*(math.pi/180)
	length=math.sqrt((s_ra-f_ra)cos(rad_f_ra))**2+(s_dec-f_dec)**2)	
	
def open_catalog(catalog_file_name,sextractor_catalog):
	x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,p_gc=([] for i in range(15))
	arr=[x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,p_gc]
	hdul=fits.open(catalog_file_name)
	data=hdul[1].data
	arr_indexes=[0,1,2,3,5,6,7,8,9,11,12,13,14,15,28]
	index=0
	for x in range(len(data)):
		sep_data=data[x]
		for y in arr_indexes:
			current_arr=arr[index]
			current_arr.append(sep_data[y])
			index=index+1
		index=0
	#opening the sextractor catalog	
	s_nmb,s_x_image,s_y_image,s_alpha,s_delta,s_a_world,s_erra_world,s_b_world,s_errb_world,s_theta_pa,s_errtheta_pa,s_elongation,s_ellip,s_mag_auto,s_magerr_auto,s_mag_best,s_magerr_best,s_mag_iso,s_magerr_iso,s_mag_isocor,s_magerr_isocor,s_mag_petro,s_magerr_petro,s_mag_aper,u_25,u_26,u_27,u_28,u_29,u_30,u_31,s_magerr_aper,u_33,u_34,u_35,u_36,u_37,u_38,u_39,s_flux_rad,s_kron_rad,s_petro_rad,s_mu_max,s_background,s_isoarea_image,s_fwhm_image,s_flags,s_class_star=np.loadtxt(sextractor_catalog,unpack=True)
	
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
		
	for fits_index in range(len(x_sex)):
		fits_obj.append(FitsObj(ra[fits_index],dec[fits_index],test_mags[fits_index]))
				
	for sex_index in range(len(s_x_image)):
		#CHANGE THE MAG_ISO VARIABLE WHEN YOUKYUNG TELLS YOU WHICH MAGNITUDE TO USE
		sex_obj.append(SextractorObj(s_alpha[sex_index],s_delta[sex_index],s_mag_aper[sex_index]))
	
	match_obj=[]
	for f in fits_obj:
		for s in sex_obj:
			if(distance(s.ra,f.ra,s.dec,f.dec)<=(1/3600)):
				match_obj.append(Match(s,f))
	for objects in match_obj:
		print(str(objects))
		
	

	

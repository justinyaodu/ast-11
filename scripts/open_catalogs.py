#code to open the catalogs from sextractor and catalog fits file and then put them into 
#arrays as seperate objects with the sorted out variables

from __future__ import division
import astropy
from astropy.io import fits
import sys
import numpy as np
import math


class SextractorObj:
	def __init__(self,ra,dec,g_mag,u_mag,i_mag,z_mag):
		self.ra=ra
		self.dec=dec
		self.g_mag=g_mag
		self.u_mag=u_mag
		self.i_mag=i_mag
		self.z_mag=z_mag
	def __str__(self):
		return "SEXTRACTOR = ra: "+str(self.ra)+ "   dec: " + str(self.dec)+"   g-magnitude: "+str(self.g_mag)+"   u-magnitude: "+str(self.u_mag)+"   i-magnitude: "+str(self.i_mag)+"   z-magnitude: "+str(self.z_mag)
class FitsObj:
	def __init__(self,ra,dec,mag):
		self.ra=ra
		self.dec=dec
		self.mag=mag
	def __str__(self):
		return "FITS = ra: "+str(self.ra)+ "   dec: " + str(self.dec)+"   magnitude: " +str(self.mag)
class Match:
	def __init__(self,sex_object,fits_object,distance):
		self.sex_object=sex_object
		self.fits_object=fits_object
		self.distance=distance
	def __str__(self):
		return "MATCHED OBJECT = "+ str(self.distance) +"\n" + "FITS ra: "+str(self.fits_object.ra)+ "   dec: " + str(self.fits_object.dec)+"   magnitude: " +str(self.fits_object.mag)+"\n"+ "SEXTRACTOR ra: "+str(self.sex_object.ra)+ "   dec: " + str(self.sex_object.dec)+"   magnitude: " +str(self.sex_object.u_mag)		
		
	
	
	
#finding the distance between the sextractor and fits catalog to find the perfect match
def distance (s_ra,f_ra,s_dec,f_dec):
	rad_f_dec=f_dec*(math.pi/180)
	length=math.sqrt(((s_ra-f_ra)*(math.cos(rad_f_dec)))**2+(s_dec-f_dec)**2)
	return length	
	
#sextractor_catalog always has to be in the g band	
def open_catalog(catalog_file_name,g_sextractor_catalog):
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
	u_sextractor_catalog=g_sextractor_catalog[0:8]+"u.cat"
	i_sextractor_catalog=g_sextractor_catalog[0:8]+"i.cat"
	z_sextractor_catalog=g_sextractor_catalog[0:8]+"z.cat"
	g_nmb,g_x_image,g_y_image,g_alpha,g_delta,g_a_world,g_erra_world,g_b_world,g_errb_world,g_theta_pa,g_errtheta_pa,g_elongation,g_ellip,g_mag_auto,g_magerr_auto,g_mag_best,g_magerr_best,g_mag_iso,g_magerr_iso,g_mag_isocor,g_magerr_isocor,g_mag_petro,g_magerr_petro,g_mag_aper,u_25,u_26,u_27,u_28,u_29,u_30,u_31,g_magerr_aper,u_33,u_34,u_35,u_36,u_37,u_38,u_39,g_flux_rad,g_kron_rad,g_petro_rad,g_mu_max,g_background,g_isoarea_image,g_fwhm_image,g_flags,g_class_star=np.loadtxt(g_sextractor_catalog,unpack=True)
	u_nmb,u_x_image,u_y_image,u_alpha,u_delta,u_a_world,u_erra_world,u_b_world,u_errb_world,u_theta_pa,u_errtheta_pa,u_elongation,u_ellip,u_mag_auto,u_magerr_auto,u_mag_best,u_magerr_best,u_mag_iso,u_magerr_iso,u_mag_isocor,u_magerr_isocor,u_mag_petro,u_magerr_petro,u_mag_aper,u1_25,u1_26,u1_27,u1_28,u1_29,u1_30,u1_31,u_magerr_aper,u1_33,u1_34,u1_35,u1_36,u1_37,u1_38,u1_39,u_flux_rad,u_kron_rad,u_petro_rad,u_mu_max,u_background,u_isoarea_image,u_fwhm_image,u_flags,u_class_star=np.loadtxt(u_sextractor_catalog,unpack=True)
	i_nmb,i_x_image,i_y_image,i_alpha,i_delta,i_a_world,i_erra_world,i_b_world,i_errb_world,i_theta_pa,i_errtheta_pa,i_elongation,i_ellip,i_mag_auto,i_magerr_auto,i_mag_best,i_magerr_best,i_mag_iso,i_magerr_iso,i_mag_isocor,i_magerr_isocor,i_mag_petro,i_magerr_petro,i_mag_aper,u2_25,u2_26,u2_27,u2_28,u2_29,u2_30,u2_31,i_magerr_aper,u2_33,u2_34,u2_35,u2_36,u2_37,u2_38,u2_39,i_flux_rad,i_kron_rad,i_petro_rad,i_mu_max,i_background,i_isoarea_image,i_fwhm_image,i_flags,i_class_star=np.loadtxt(i_sextractor_catalog,unpack=True)
	z_nmb,z_x_image,z_y_image,z_alpha,z_delta,z_a_world,z_erra_world,z_b_world,z_errb_world,z_theta_pa,z_errtheta_pa,z_elongation,z_ellip,z_mag_auto,z_magerr_auto,z_mag_best,z_magerr_best,z_mag_iso,z_magerr_iso,z_mag_isocor,z_magerr_isocor,z_mag_petro,z_magerr_petro,z_mag_aper,u3_25,u3_26,u3_27,u3_28,u3_29,u3_30,u3_31,z_magerr_aper,u3_33,u3_34,u3_35,u3_36,u3_37,u3_38,u3_39,z_flux_rad,z_kron_rad,z_petro_rad,z_mu_max,z_background,z_isoarea_image,z_fwhm_image,z_flags,z_class_star=np.loadtxt(z_sextractor_catalog,unpack=True)
	
	#making the objects
	band_name=g_sextractor_catalog[8]
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
				
	for sex_index in range(len(g_x_image)):
		#CHANGE THE MAG_ISO VARIABLE WHEN YOUKYUNG TELLS YOU WHICH MAGNITUDE TO USE
		sex_obj.append(SextractorObj(g_alpha[sex_index],g_delta[sex_index],g_mag_aper[sex_index],u_mag_aper[sex_index],i_mag_aper[sex_index],z_mag_aper[sex_index]))
	
	'''for sex_objects in sex_obj:
		print(sex_objects)'''
	match_obj=[]
	for f in fits_obj:
		for s in sex_obj:
			current_distance=distance(s.ra,f.ra,s.dec,f.dec)
			if(current_distance<=(1/3600)):
				match_obj.append(Match(s,f,current_distance))
	for objects in match_obj:
		print("\n"+str(objects))
		
	

	

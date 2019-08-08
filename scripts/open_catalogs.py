#FINAL GOAL: FIND POINT SOURCES
#what this code does: code to open the catalogs from sextractor and catalog fits file
#put them into arrays as seperate objects with the sorted out variables
#find matched objects in between the sextractor catalog and the fits catalog
#do some stuff with this (like finding the corrected pixel magnitude and finding the IC to detect point sources)

from __future__ import division
import astropy
from astropy.io import fits
import sys
import numpy as np
import math
from sklearn.linear_model import LinearRegression

class SextractorObj:
	def __init__(self,ra,dec,g_mag,u_mag,i_mag,z_mag,g_four,g_eight,u_four,u_eight,i_four,i_eight,z_four,z_eight):
		self.ra=ra
		self.dec=dec
		self.g_mag=g_mag
		self.u_mag=u_mag
		self.i_mag=i_mag
		self.z_mag=z_mag
		self.g_four=g_four
		self.g_eight=g_eight
		self.u_four=u_four
		self.u_eight=u_eight
		self.i_four=i_four
		self.i_eight=i_eight
		self.z_four=z_four
		self.z_eight=z_eight
	def __str__(self):
		return "SEXTRACTOR = ra: "+str(self.ra)+ "   dec: " + str(self.dec)+"   g-magnitude: "+str(self.g_mag)+"   u-magnitude: "+str(self.u_mag)+"   i-magnitude: "+str(self.i_mag)+"   z-magnitude: "+str(self.z_mag)
class CorrectedSextractorObj:	
	def __init__(self,ra,dec,g_mag,u_mag,i_mag,z_mag,g_corr_four,g_corr_eight,u_corr_four,u_corr_eight,i_corr_four,i_corr_eight,z_corr_four,z_corr_eight,inRange):
		self.ra=ra
		self.dec=dec
		self.g_mag=g_mag
		self.u_mag=u_mag
		self.i_mag=i_mag
		self.z_mag=z_mag
		self.g_corr_four=g_corr_four
		self.g_corr_eight=g_corr_eight
		self.u_corr_four=u_corr_four
		self.u_corr_eight=u_corr_eight
		self.i_corr_four=i_corr_four
		self.i_corr_eight=i_corr_eight
		self.z_corr_four=z_corr_four
		self.z_corr_eight=z_corr_eight
		self.inRange=inRange
	def __str__(self):
		return "Corrected SEXTRACTOR:" + "\n" + "g_corr_4: "+str(self.g_corr_four)+ "\n" + "g_corr_eight: " + str(self.g_corr_eight)+ "\n" +"u_corr_four: "+str(self.u_corr_four)+ "\n" + "u_corr_eight: "+str(self.u_corr_eight)+ "\n" +"i_corr_four: "+str(self.i_corr_four)+ "\n" +"i_corr_eight: "+str(self.i_corr_eight)+ "\n" +"z_corr_four: "+str(self.z_corr_four)+ "\n" +"z_corr_eight: "+str(self.z_corr_eight)
class FitsObj:
	def __init__(self,ra,dec,mag,corr_index,gmag,umag,imag,zmag):
		self.ra=ra
		self.dec=dec
		self.mag=mag
		self.corr_index=corr_index
		self.gmag=gmag
		self.umag=umag
		self.imag=imag
		self.zmag=zmag

	def __str__(self):
		return "FITS = ra: "+str(self.ra)+ "   dec: " + str(self.dec)+"   magnitude: " +str(self.mag)+"   IC: " +str(self.corr_index)
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
	x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,ic,p_gc=([] for i in range(16))
	arr=[x_sex,y_sex,ra,dec,umag,gmag,rmag,imag,zmag,umagerr,gmagerr,rmagerr,imagerr,zmagerr,ic,p_gc]
	hdul=fits.open(catalog_file_name)
	data=hdul[1].data
	arr_indexes=[0,1,2,3,5,6,7,8,9,11,12,13,14,15,17,28]
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
	g_nmb,g_x_image,g_y_image,g_alpha,g_delta,g_a_world,g_erra_world,g_b_world,g_errb_world,g_theta_pa,g_errtheta_pa,g_elongation,g_ellip,g_mag_auto,g_magerr_auto,g_mag_best,g_magerr_best,g_mag_iso,g_magerr_iso,g_mag_isocor,g_magerr_isocor,g_mag_petro,g_magerr_petro,g_mag_aper,g_four,u_26,u_27,u_28,g_eight,u_30,u_31,g_magerr_aper,u_33,u_34,u_35,u_36,u_37,u_38,u_39,g_flux_rad,g_kron_rad,g_petro_rad,g_mu_max,g_background,g_isoarea_image,g_fwhm_image,g_flags,g_class_star=np.loadtxt(g_sextractor_catalog,unpack=True)
	u_nmb,u_x_image,u_y_image,u_alpha,u_delta,u_a_world,u_erra_world,u_b_world,u_errb_world,u_theta_pa,u_errtheta_pa,u_elongation,u_ellip,u_mag_auto,u_magerr_auto,u_mag_best,u_magerr_best,u_mag_iso,u_magerr_iso,u_mag_isocor,u_magerr_isocor,u_mag_petro,u_magerr_petro,u_mag_aper,u_four,u1_26,u1_27,u1_28,u_eight,u1_30,u1_31,u_magerr_aper,u1_33,u1_34,u1_35,u1_36,u1_37,u1_38,u1_39,u_flux_rad,u_kron_rad,u_petro_rad,u_mu_max,u_background,u_isoarea_image,u_fwhm_image,u_flags,u_class_star=np.loadtxt(u_sextractor_catalog,unpack=True)
	i_nmb,i_x_image,i_y_image,i_alpha,i_delta,i_a_world,i_erra_world,i_b_world,i_errb_world,i_theta_pa,i_errtheta_pa,i_elongation,i_ellip,i_mag_auto,i_magerr_auto,i_mag_best,i_magerr_best,i_mag_iso,i_magerr_iso,i_mag_isocor,i_magerr_isocor,i_mag_petro,i_magerr_petro,i_mag_aper,i_four,u2_26,u2_27,u2_28,i_eight,u2_30,u2_31,i_magerr_aper,u2_33,u2_34,u2_35,u2_36,u2_37,u2_38,u2_39,i_flux_rad,i_kron_rad,i_petro_rad,i_mu_max,i_background,i_isoarea_image,i_fwhm_image,i_flags,i_class_star=np.loadtxt(i_sextractor_catalog,unpack=True)
	z_nmb,z_x_image,z_y_image,z_alpha,z_delta,z_a_world,z_erra_world,z_b_world,z_errb_world,z_theta_pa,z_errtheta_pa,z_elongation,z_ellip,z_mag_auto,z_magerr_auto,z_mag_best,z_magerr_best,z_mag_iso,z_magerr_iso,z_mag_isocor,z_magerr_isocor,z_mag_petro,z_magerr_petro,z_mag_aper,z_four,u3_26,u3_27,u3_28,z_eight,u3_30,u3_31,z_magerr_aper,u3_33,u3_34,u3_35,u3_36,u3_37,u3_38,u3_39,z_flux_rad,z_kron_rad,z_petro_rad,z_mu_max,z_background,z_isoarea_image,z_fwhm_image,z_flags,z_class_star=np.loadtxt(z_sextractor_catalog,unpack=True)
	
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
		fits_obj.append(FitsObj(ra[fits_index],dec[fits_index],test_mags[fits_index],ic[fits_index],gmag[fits_index],umag[fits_index],imag[fits_index],zmag[fits_index]))
				
	for sex_index in range(len(g_x_image)):
		#CHANGE THE MAG_ISO VARIABLE WHEN YOUKYUNG TELLS YOU WHICH MAGNITUDE TO USE
		sex_obj.append(SextractorObj(g_alpha[sex_index],g_delta[sex_index],g_mag_aper[sex_index],u_mag_aper[sex_index],i_mag_aper[sex_index],z_mag_aper[sex_index],g_four[sex_index],g_eight[sex_index],u_four[sex_index],u_eight[sex_index],i_four[sex_index],i_eight[sex_index],z_four[sex_index],z_eight[sex_index]))
	
	#finding the matched objects between the sextractor catalog and the fits catalog
	match_obj=[]
	for f in fits_obj:
		for s in sex_obj:
			current_distance=distance(s.ra,f.ra,s.dec,f.dec)
			if(current_distance<=(1/3600)):
				match_obj.append(Match(s,f,current_distance))
	
	#finding point sources from the matched fits object
	point_source=[]
	for obj in match_obj:
		if obj.fits_object.corr_index<0.1:
			point_source.append(obj)
			
	#to find linear regression: use commented-out code below		
	'''gfour=[]
	geight=[]
	ufour=[]
	ueight=[]
	ifour=[]
	ieight=[]
	zfour=[]
	zeight=[]
	aper_cor_gmag=[]
	aper_cor_umag=[]
	aper_cor_imag=[]
	aper_cor_zmag=[]
	for obj in point_source:
		gfour.append(obj.sex_object.g_four)
		geight.append(obj.sex_object.g_eight)
		ufour.append(obj.sex_object.u_four)
		ueight.append(obj.sex_object.u_eight)
		ifour.append(obj.sex_object.i_four)
		ieight.append(obj.sex_object.i_eight)
		zfour.append(obj.sex_object.z_four)
		zeight.append(obj.sex_object.z_eight)
		aper_cor_gmag.append(obj.fits_object.gmag)
		aper_cor_umag.append(obj.fits_object.umag)
		aper_cor_imag.append(obj.fits_object.imag)
		aper_cor_zmag.append(obj.fits_object.zmag)
	four_pixel_mag_arrays=dict()
	four_pixel_mag_arrays["u"]=ufour
	four_pixel_mag_arrays["g"]=gfour
	four_pixel_mag_arrays["i"]=ifour 
	four_pixel_mag_arrays["z"]=zfour
	eight_pixel_mag_arrays=dict()
	eight_pixel_mag_arrays["u"]=ueight
	eight_pixel_mag_arrays["g"]=geight
	eight_pixel_mag_arrays["i"]=ieight 
	eight_pixel_mag_arrays["z"]=zeight 
	aper_cor_mag_arrays=dict()
	aper_cor_mag_arrays["u"]=aper_cor_umag 
	aper_cor_mag_arrays["g"]=aper_cor_gmag
	aper_cor_mag_arrays["i"]=aper_cor_imag 
	aper_cor_mag_arrays["z"]=aper_cor_zmag 
	for band in "u""g""i""z":
		#my_four=four_pixel_mag_arrays[band]
		my_eight=eight_pixel_mag_arrays[band]
		my_aper=aper_cor_mag_arrays[band]
		x = np.array(my_eight).reshape(-1,1)
		y = my_aper
		model = LinearRegression().fit(x, y)
		print(band)
		print("intercept: " + str(model.intercept_))
		print("slope: " + str(model.coef_))'''
		
	#found these slope and intercept values from the code commented above
	#these equations below are used to find the corrected pixel magnitudes for 4px and 8px
	for obj in sex_obj:
		index=0
		g_corr_four=(0.8356859*obj.g_four)+4.126092533190409
		g_corr_eight=(0.83805141*obj.g_eight)+4.4296660274459505
		u_corr_four=(1.22978512*obj.u_four)-6.6390897878619235
		u_corr_eight=(1.22608518*obj.u_eight)-5.605123805346295
		i_corr_four=( 0.99802054*obj.i_four)-0.5124901699508975
		i_corr_eight=(0.99959828*obj.i_eight)-0.12177102767153514
		z_corr_four=(0.98753496*obj.z_four)-1.1294699641616717
		z_corr_eight=(0.9920881*obj.z_eight)-0.32163449904708585
		obj=CorrectedSextractorObj(g_alpha[index],g_delta[index],g_mag_aper[index],u_mag_aper[index],i_mag_aper[index],z_mag_aper[index],g_corr_four,g_corr_eight,u_corr_four,u_corr_eight,i_corr_four,i_corr_eight,z_corr_four,z_corr_eight,False)
		index=index+1
		
	#finding the concentration index (IC) using iband and also checking the color restrictions
	counter=0
	for obj in sex_obj:
		difference=obj.i_corr_four-obj.i_corr_eight
		if difference>=-0.1 && difference<=0.15:
			#just use four pixel numbers for now but make sure to check what youkyung says
			x_coord=u_corr_four-g_corr_four
			y_coord=g_corr_four-i_corr_four
			if (x_coord>0.8 && x_coord<1.9) && (y_coord<1.7 && y_coord>1):
				if y_coord<(0.56*x_coord)+0.85 && y_coord>(0.6*x_coord)+0.35:
					obj.inRange=True
					counter=counter+1
	print(len(sex_obj))
	print(counter)

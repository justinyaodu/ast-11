def gen_geompar(filepath,x0=1024,y0=1024,ellip0=0.2,pa0=0,sma0=10,minsma=0,maxsma=700,step=0.1,linear="no",maxrit="INDEF",recenter="yes",xylearn="yes",physical="yes"):
    file = open(filepath, 'w')
    file.write("x0,r,h," + str(x0) + ".,1.,,\"initial isophote center X\"\n")
    file.write("y0,r,h," + str(y0) + ".,1.,,\"initial isophote center Y\"\n")
    file.write("ellip0,r,h," + str(ellip0) + ",0.05,1.,\"initial ellipticity\"\n")
    file.write("pa0,r,h," + str(pa0) + ",-90.,90.,\"initial position angle (degrees)\"\n")
    file.write("sma0,r,h," + str(sma0) + ",5.,,\"initial semi-major axis length\"\n")
    file.write("minsma,r,h," + str(minsma) + ",0.,,\"minimum semi-major axis length\"\n")
    file.write("maxsma,r,h," + str(maxsma) + ",1.,,\"maximum semi-major axis length\"\n")
    file.write("step,r,h," + str(step) + ",0.001,,\"sma step between successive ellipses\"\n")
    file.write("linear,b,h," + str(linear) + ",,,\"linear sma step ?\"\n")
    file.write("maxrit,r,h," + str(maxrit) + ",0.,,\"maximum sma length for iterative mode\"\n")
    file.write("recenter,b,h," + str(recenter) + ",,,\"allows finding routine to re-center x0-y0 ?\"\n")
    file.write("xylearn,b,h," + str(xylearn) + ",,,\"updates pset with new x0-y0 ?\"\n")
    file.write("physical,b,h," + str(physical) + ",,,\"physical coordinate system ?\"\n")
    file.write("mode,s,h,\"al\",,,\n")
    file.close()


""" (Generate this in a file)

x0,r,h,1024.,1.,,"initial isophote center X"
y0,r,h,1024.,1.,,"initial isophote center Y"
ellip0,r,h,0.2,0.05,1.,"initial ellipticity"
pa0,r,h,20.,-90.,90.,"initial position angle (degrees)"
sma0,r,h,10.,5.,,"initial semi-major axis length"
minsma,r,h,0.,0.,,"minimum semi-major axis length"
maxsma,r,h,700.,1.,,"maximum semi-major axis length"
step,r,h,0.1,0.001,,"sma step between successive ellipses"
linear,b,h,no,,,"linear sma step ?"
maxrit,r,h,INDEF,0.,,"maximum sma length for iterative mode"
recenter,b,h,yes,,,"allows finding routine to re-center x0-y0 ?"
xylearn,b,h,yes,,,"updates pset with new x0-y0 ?"
physical,b,h,yes,,,"physical coordinate system ?"
mode,s,h,"al",,,

"""

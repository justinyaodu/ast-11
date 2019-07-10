import numpy as np

def get_fake_data(table_print_file):
    # read in file columns as numpy arrays
    row_num, sma, ellip, pa, x0, y0 = np.loadtxt(table_print_file, unpack=True)

    # for SMA, returns largest value
    # for ellipticity, position angle, and position,
    # return median of last ten values
    print "sma  :", sma[-1]
    print "ellip:", np.median(ellip[-10:])
    print "pa   :", np.median(pa[-10:])
    print "x0   :", np.median(x0[-10:])
    print "y0   :", np.median(y0[-10:])

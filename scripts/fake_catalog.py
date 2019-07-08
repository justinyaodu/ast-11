import numpy as np

def get_fake_data(table_print_file):
    # read in file columns as numpy arrays
    row_num, sma, ellip, pa = np.loadtxt(table_print_file, unpack=True)

    # for SMA, returns largest value
    # for ellipticity and position angle, return median of last ten values
    print "sma  :", sma[-1]
    print "ellip:", np.median(ellip[-10:])
    print "pa   :", np.median(pa[-10:])

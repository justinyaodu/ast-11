import os

if __name__ == '__main__':
    f = open("generated_runscript.sh","w")
    for filename in os.listdir("."):
        if filename.endswith("_sig.fits"):
            continue
        file = filename[":-5"]
        f.write("./isofit_model.sh " + file + " remove\n")
    f.write("\n")
    f.close()

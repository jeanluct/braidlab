Import('env')
import glob

# List of files to compile into library (remove program frontend.cpp)
liblist = [f for f in glob.glob('*.cpp') if f not in ['frontend.cpp']]

lib = env.Library('trains', liblist)
env.NoClean(lib)

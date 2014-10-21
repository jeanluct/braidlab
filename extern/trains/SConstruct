env = Environment(CC = 'gcc',
                  CCFLAGS = '-Wall -O3 -ffast-math',
                  CPPPATH = '.')

SConscript('SConscript', exports = 'env')

env.Program('frontend.cpp', LIBS = 'trains', LIBPATH = '.')

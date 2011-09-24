# Makefile for building MEX files from C and CPP sources.

# Extract architecture, compiler, etc. from MEX configuration.
MEX         = mex
MEXENV      = $(MEX) -v 2> /dev/null
MEXOPTSFILE = $(strip $(shell $(MEXENV) | grep "^ *FILE *=" | cut -d = -f 2))
MEXSUFFIX   = $(strip $(shell $(MEXENV) | \
		grep "^ *LDEXTENSION *=" | cut -d = -f 2 | cut -d . -f 2))
CXX         = $(strip $(shell $(MEXENV) | grep "\-> *CXX *=" | cut -d = -f 2))
CC          = $(strip $(shell $(MEXENV) | grep "\-> *CC *=" | cut -d = -f 2))
MATLABHOME  = $(strip $(shell $(MEXENV) | \
		grep "\-> *MATLAB *=" | cut -d = -f 2))

CFLAGS     = -fPIC -ansi -pthread -DMX_COMPAT_32 -DMATLAB_MEX_FILE
#LIBS      = -lm
#INCLUDE   = -I$(MATLABHOME)/extern/include
#MEXFLAGS  = 

CBRAID_LIBDIR     = ../../../cbraid/lib
CBRAID_INCLUDEDIR = ../../../cbraid/include
CBRAID_LD         = -lcbraid

%.$(MEXSUFFIX): %.c
	$(MEX) $(MEXFLAGS) $(LIBS) $^

%.$(MEXSUFFIX): %.cpp
	# Rebuild libcbraid.a with the MEX-compatible compiler.
	cd $(CBRAID_LIBDIR); make clean ; make CXX=$(CXX) CC=$(CC)
	$(MEX) $(MEXFLAGS) $^ \
		-I$(CBRAID_INCLUDEDIR) -L$(CBRAID_LIBDIR) $(CBRAID_LD)

#loopsigma_helper.$(MEXSUFFIX): loopsigma_helper.c

all: cfbraid_helper.$(MEXSUFFIX) conjtest_helper.$(MEXSUFFIX)

showvars:
	@echo "$(MEXSUFFIX)"
	@echo "$(MEXOPTSFILE)"
	@echo "$(CC)"
	@echo "$(CXX)"
	@echo "$(MATLABHOME)"

clean:
	rm -f *.$(MEXSUFFIX) *.o

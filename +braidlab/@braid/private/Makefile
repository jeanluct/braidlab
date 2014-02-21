# Makefile for building MEX files from C and CPP sources.

# <LICENSE
#   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
#
#   This file is part of Braidlab.
#
#   Braidlab is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Braidlab is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
# LICENSE>

# Extract architecture, compiler, etc. from MEX configuration.
MEX         = mex
MEXENV      = $(MEX) -v 2> /dev/null
MEXVOUT     := $(shell $(MEXENV))
MEXOPTSFILE = $(strip $(shell $(MEXENV) | grep "^ *FILE *=" | cut -d = -f 2))
MEXSUFFIX   = $(strip $(shell $(MEXENV) | \
		grep "^ *LDEXTENSION *=" | cut -d = -f 2 | cut -d . -f 2))
CXX         = $(strip $(shell $(MEXENV) | grep "\-> *CXX *=" | cut -d = -f 2))
CC          = $(strip $(shell $(MEXENV) | grep "\-> *CC *=" | cut -d = -f 2))
MATLABHOME  = $(strip $(shell $(MEXENV) | \
		grep "\-> *MATLAB *=" | cut -d = -f 2))

CFLAGS     = $(strip $(shell $(MEXENV) | grep "CFLAGS *=" | cut -d = -f 2)) -fPIC -ansi -pthread -DMX_COMPAT_32 -DMATLAB_MEX_FILE

#LIBS      = -lm
#INCLUDE   = -I$(MATLABHOME)/extern/include
MEXFLAGS  = -largeArrayDims CFLAGS="${CFLAGS}"

CBRAID_LIBDIR     = ../../../extern/cbraid/lib
CBRAID_INCLUDEDIR = ../../../extern/cbraid/include
CBRAID_LD         = -lcbraid-mex

TRAINS_LIBDIR     = ../../../extern/trains
TRAINS_INCLUDEDIR = ../../../extern
TRAINS_LD         = -ltrains

ifdef BRAIDLAB_USE_GMP
GMP_LD = -lgmpxx -lgmp
MEXFLAGS += -DBRAIDLAB_USE_GMP
endif

%.$(MEXSUFFIX): %.cpp
ifndef MEXVOUT
	$(error Matlab "mex" command is not in your path)
endif
	# Rebuild libcbraid-mex.a with the MEX-compatible compiler.
	cd $(CBRAID_LIBDIR); \
		make -f ../../../Makefile.cbraid-mex CXX=$(CXX) CC=$(CC)
	$(MEX) $(MEXFLAGS) $^ \
		-I$(CBRAID_INCLUDEDIR) -L$(CBRAID_LIBDIR) $(CBRAID_LD)

all: compact_helper.$(MEXSUFFIX) loopsigma_helper.$(MEXSUFFIX) entropy_helper.$(MEXSUFFIX) tntype_helper.$(MEXSUFFIX)

tntype_helper.$(MEXSUFFIX): tntype_helper.cpp
ifndef MEXVOUT
	$(error Matlab "mex" command is not in your path)
endif
	cd $(TRAINS_LIBDIR); \
		make CXX="$(CXX) -fPIC" CC=$(CC)
	$(MEX) $(MEXFLAGS) $^ \
		-I$(TRAINS_INCLUDEDIR) -L$(TRAINS_LIBDIR) $(TRAINS_LD)

loopsigma_helper.$(MEXSUFFIX): loopsigma_helper.cpp \
	loopsigma_helper_common.hpp update_rules.hpp sumg.hpp
ifndef MEXVOUT
	$(error Matlab "mex" command is not in your path)
endif
	# $< is the first dependency (the .cpp file).
	$(MEX) $(MEXFLAGS) $< $(GMP_LD)

showvars:
	@echo "$(MEXSUFFIX)"
	@echo "$(MEXOPTSFILE)"
	@echo "$(CC)"
	@echo "$(CXX)"
	@echo "$(MATLABHOME)"
	@echo "$(CFLAGS)"
clean:
	rm -f *.$(MEXSUFFIX) *.o

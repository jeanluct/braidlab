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

CFLAGS     = -fPIC -ansi -pthread -DMX_COMPAT_32 -DMATLAB_MEX_FILE
#LIBS      = -lm
#INCLUDE   = -I$(MATLABHOME)/extern/include
MEXFLAGS  = -compatibleArrayDims  # For now build for arrays of size 2^32-1.

%.$(MEXSUFFIX): %.c
ifndef MEXVOUT
	$(error Matlab "mex" command is not in your path)
endif
	$(MEX) $(MEXFLAGS) $(LIBS) $^

%.$(MEXSUFFIX): %.cpp
ifndef MEXVOUT
	$(error Matlab "mex" command is not in your path)
endif
	$(MEX) $(MEXFLAGS) $^

all: randomwalk_helper.$(MEXSUFFIX)

showvars:
	@echo "$(MEXSUFFIX)"
	@echo "$(MEXOPTSFILE)"
	@echo "$(CC)"
	@echo "$(CXX)"
	@echo "$(MATLABHOME)"

clean:
	rm -f *.$(MEXSUFFIX) *.o

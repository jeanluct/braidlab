# Makefile for building MEX files from C and CPP sources.

# <LICENSE
#   Braidlab: a Matlab package for analyzing data using braids
#
#   http://github.com/jeanluct/braidlab
#
#   Copyright (C) 2013-2021  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
#                            Marko Budisic          <marko@clarkson.edu>
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

CBRAID_DIR        = ../../../extern/cbraid
CBRAID_LIBDIR     = $(CBRAID_DIR)/lib
CBRAID_INCLUDEDIR = $(CBRAID_DIR)/include
CBRAID_LD         = -lcbraid-mex

TRAINS_DIR        = ../../../extern/trains
TRAINS_LIBDIR     = $(TRAINS_DIR)/lib
TRAINS_INCLUDEDIR = $(TRAINS_DIR)
TRAINS_LD         = -ltrains

# Need override since variable usually set as command-line argument.
#
# Wouldn't need this if we could pass a quoted string inside of
# another quoted string, but this is a simple kludge.
override MEXFLAGS += CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)"

.PHONY: check-env all clean

all: check-env compact_helper.$(MEXSUFFIX) loopsigma_helper.$(MEXSUFFIX) entropy_helper.$(MEXSUFFIX) train_helper.$(MEXSUFFIX) cross2gen_helper.$(MEXSUFFIX) subbraid_helper.$(MEXSUFFIX)

check-env:
ifndef MEX
# Variables not defined properly if run from local folder.
	$(error Run make from braidlab root folder)
endif

%.$(MEXSUFFIX): %.cpp
# Rebuild libcbraid-mex.a with the MEX-compatible compiler.
	cd $(CBRAID_LIBDIR); \
		make -f ../../../Makefile.cbraid-mex CXX=$(CXX) CC=$(CC)
	$(MEX) $(MEXFLAGS) $^ \
		-I$(CBRAID_INCLUDEDIR) -L$(CBRAID_LIBDIR) $(CBRAID_LD)

train_helper.$(MEXSUFFIX): train_helper.cpp
	cd $(TRAINS_DIR); \
		make CXX="$(CXX) -fPIC" CC=$(CC)
	$(MEX) $(MEXFLAGS) $^ \
		-I$(TRAINS_INCLUDEDIR) -L$(TRAINS_LIBDIR) $(TRAINS_LD)

loopsigma_helper.$(MEXSUFFIX): loopsigma_helper.cpp \
	loopsigma_helper_common.hpp update_rules.hpp sumg.hpp ThreadPool.h
# $< is the first dependency (the .cpp file).
	$(MEX) $(MEXFLAGS) $< $(GMP_LD)

entropy_helper.$(MEXSUFFIX): entropy_helper.cpp \
	update_rules.hpp ../../@loop/private/loop_helper.hpp
# $< is the first dependency (the .cpp file).
	$(MEX) $(MEXFLAGS) $< $(GMP_LD)

cross2gen_helper.$(MEXSUFFIX): cross2gen_helper.cpp \
	cross2gen_helper.hpp ThreadPool.h
# $< is the first dependency (the .cpp file).
	$(MEX) $(MEXFLAGS) $< $(GMP_LD)

clean:
	rm -f *.$(MEXSUFFIX) *.o

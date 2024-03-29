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

# Need override since variable usually set as command-line argument.
#
# Wouldn't need this if we could pass a quoted string inside of
# another quoted string, but this is a simple kludge.
override MEXFLAGS += CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)"

.PHONY: check-env all clean

all: check-env randomwalk_helper.$(MEXSUFFIX)

check-env:
ifndef MEX
	# Variables not defined properly if run from local folder.
	$(error Run make from braidlab root folder)
endif

%.$(MEXSUFFIX): %.c
	$(MEX) $(MEXFLAGS) $(LIBS) $^

%.$(MEXSUFFIX): %.cpp
	$(MEX) $(MEXFLAGS) $^

clean:
	rm -f *.$(MEXSUFFIX) *.o

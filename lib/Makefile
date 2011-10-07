#   Copyright (C) 2000-2001 Jae Choon Cha.
#
#   This file is part of CBraid.
#
#   CBraid is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   any later version.
#
#   CBraid is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with CBraid; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

#
# Addendum by Jean-Luc Thiffeault (2011/09/15):
#
#   JLT: Folded Juan Gonzalez-Meneses' "braiding" library (which
#   depends on CBraid) into this Makefile.  libcbraid.a will contain
#   cbraid.o and braiding.o.

# File Names.
LIBCBRAID_SRC = cbraid.cpp braiding.cpp
LIBCBRAID_INCLUDEDIR = ../include
LIBCBRAID_OBJ = $(LIBCBRAID_SRC:.cpp=.o)
LIBCBRAID_A = libcbraid.a
LIBCBRAID_CLEAN = $(LIBCBRAID_OBJ) $(LIBCBRAID_A)

# Compile options.
#CPPFLAGS_CLN = -DUSE_CLN
ifeq ($(CPPFLAGS_CLN),-DUSE_CLN)
	LIBFLAGS_CLN = -lcln
endif
CPPFLAGS = -Wall -O -I$(LIBCBRAID_INCLUDEDIR) $(CPPFLAGS_CLN)
LIBFLAGS = -lcbraid -lm $(LIBFLAGS_CLN)
ARFLAGS = rv
CXX = g++

MAKEDEPCMD = $(CXX)
MAKEDEPFLAGS = -M
DEPFILE = .depends

# Default target.
all: $(LIBCBRAID_A)

# Default compile rules.
.cpp.o:
	$(CXX) $(CPPFLAGS) -c $<

# Build libcbraid.
$(LIBCBRAID_A): $(LIBCBRAID_OBJ)
	$(AR) $(ARFLAGS) $@ $?

$(LIBCBRAID_OBJ): $(LIBCBRAID_SRC)

# Cleanup.
clean:
	rm -f $(LIBCBRAID_CLEAN)
	rm -f $(DEPFILE)

# Make dependencies.
depend:
	rm -f $(DEPFILE)
	make $(DEPFILE)

# Make dependencies file.
$(DEPFILE):
	$(MAKEDEPCMD) $(MAKEDEPFLAGS) $(LIBCBRAID_SRC) \
		-I$(LIBCBRAID_INCLUDEDIR) > $(DEPFILE)

# Read in dependencies file created by 'make depend'.
sinclude $(DEPFILE)

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

#   JLT: Folded Juan Gonzalez-Meneses' "braiding" program (which
#   depends on CBraid) into this Makefile.

# File names
LIBCBRAID=../lib/libcbraid.a

# Compile options.
#CPPFLAGS_CLN=-DUSE_CLN
#LIBFLAGS_CLN=-lcln

CPPFLAGS=-Wall -O -I../include -L../lib $(CPPFLAGS_CLN)
LIBFLAGS=-lcbraid $(LIBFLAGS_CLN)

# Default arguments for test programs.
TEST_ARG=

# Default compile rules
.cpp.o:
	$(CXX) $(CPPFLAGS) -c $<

# Default target.
all: test speedtest braiding

# Build library
$(LIBCBRAID):
	cd ../lib; make libcbraid.a

# Sample programs.
do-test: test
	./test $(TEST_ARG)

test: test.cpp optarg.h $(LIBCBRAID)
	$(CXX) $(CPPFLAGS) -o test test.cpp $(LIBFLAGS)

do-speedtest: speedtest
	./speedtest $(SPEEDTEST_ARG)

speedtest: speedtest.cpp optarg.h timecounter.h $(LIBCBRAID)
	$(CXX) $(CPPFLAGS) -o speedtest speedtest.cpp $(LIBFLAGS)

braiding: braiding_main.cpp $(LIBCBRAID)
	$(CXX) $(CPPFLAGS) -o braiding braiding_main.cpp $(LIBFLAGS)

# Cleanup.
clean:
	rm -rf $(LIBCBRAID_CLEAN) test speedtest braiding *.o

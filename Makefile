# <LICENSE
#   Braidlab: a Matlab package for analyzing data using braids
#
#   https://github.com/jeanluct/braidlab
#
#   Copyright (C) 2013-2026  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
#                            Marko Budisic          <mbudisic@gmail.com>
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
#   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
# LICENSE>

# Find architecture, set corresponding mex file suffix.
# Linux and Darwin return exact matches from uname -s.
# Windows environments (MINGW, MSYS, Cygwin) return version-specific strings
# like MINGW64_NT-10.0-19045, so we use findstring to match the prefix.
SYS = $(shell uname -s)
ARCH = $(shell uname -m)
ifeq ($(SYS), Linux)
	# Linux: x86_64 (Intel/AMD 64-bit), aarch64 (ARM 64-bit), i686 (32-bit)
	ifeq ($(ARCH), x86_64)
		MEXSUFFIX = mexa64
	else ifeq ($(ARCH), aarch64)
		MEXSUFFIX = mexa64
	else ifeq ($(ARCH), i686)
		MEXSUFFIX = mexglx
	endif
else ifeq ($(SYS), Darwin)
	# macOS: x86_64 (Intel), arm64 (Apple Silicon M1/M2/M3)
	ifeq ($(ARCH), x86_64)
		MEXSUFFIX = mexmaci64
	else ifeq ($(ARCH), arm64)
		MEXSUFFIX = mexmaca64
	endif
else ifneq (,$(findstring MINGW,$(SYS)))
	# MINGW64 or MINGW32 on Windows
	ifeq ($(ARCH), x86_64)
		MEXSUFFIX = mexw64
	else
		MEXSUFFIX = mexw32
	endif
else ifneq (,$(findstring MSYS,$(SYS)))
	# MSYS2 on Windows
	ifeq ($(ARCH), x86_64)
		MEXSUFFIX = mexw64
	else
		MEXSUFFIX = mexw32
	endif
else ifneq (,$(findstring CYGWIN,$(SYS)))
	# Cygwin on Windows
	ifeq ($(ARCH), x86_64)
		MEXSUFFIX = mexw64
	else
		MEXSUFFIX = mexw32
	endif
endif

export MEXSUFFIX

# Set MACOSX deployment target to the major SDK version (e.g. 15.0)
# when on Darwin
ifeq ($(SYS), Darwin)
	SDKVER := $(shell xcrun --sdk macosx --show-sdk-version 2>/dev/null || echo)
	ifneq ($(SDKVER),)
		SDKMAJOR := $(firstword $(subst ., ,$(SDKVER)))
		MACOSX_DEPLOYMENT_TARGET ?= $(SDKMAJOR).0
	endif
endif

MEX = mex
CFLAGS = -O -DMATLAB_MEX_FILE -fPIC
# C++11 is needed for parallel code.
CXXFLAGS = $(CFLAGS) -std=c++11
MEXFLAGS = -largeArrayDims -O

# Modify MEXFLAGS to exclude unsupported flags on macOS
ifeq ($(SYS), Darwin)
	MEXFLAGS := $(filter-out LDFLAGS='-z noexecstack', $(MEXFLAGS))
endif

# Use BRAIDLAB_USE_GMP=0 on command line to disable GMP if desired.
# If BRAIDLAB_USE_GMP is not set, try to detect available GMP libraries
# and disable GMP automatically when they are not present. This avoids
# failing the build on systems without libgmp / libgmpxx installed.
ifndef BRAIDLAB_USE_GMP
# Test by attempting to link a tiny program against gmpxx and gmp.
# Use a one-line shell command that pipes source to the compiler to avoid
# issues with multi-line heredocs inside make's $(shell ...).
GMP_CHECK := $(shell printf 'int main(void){return 0;}' \
	| cc -x c - -lgmpxx -lgmp -o /tmp/_braidlab_gmp_test 2>/dev/null \
	&& echo yes || echo no; rm -f /tmp/_braidlab_gmp_test 2>/dev/null)
ifeq ($(GMP_CHECK),yes)
	BRAIDLAB_USE_GMP = 1
else
	BRAIDLAB_USE_GMP = 0
	$(info GMP libraries not found; building without GMP support.)
endif
endif

ifneq ($(BRAIDLAB_USE_GMP), 0)
	# If Homebrew installed gmp, prefer its lib/include paths
	# (Apple Silicon: /opt/homebrew)
	BREW_GMP_PREFIX := $(shell brew --prefix gmp 2>/dev/null || echo)
	ifneq ($(BREW_GMP_PREFIX),)
		GMP_LD = -L$(BREW_GMP_PREFIX)/lib -lgmpxx -lgmp
		CFLAGS += -I$(BREW_GMP_PREFIX)/include
		CXXFLAGS += -I$(BREW_GMP_PREFIX)/include
	else
		GMP_LD = -lgmpxx -lgmp
	endif
	MEXFLAGS += -DBRAIDLAB_USE_GMP
else
	GMP_LD =
endif

MAKEMEX = make MEX=$(MEX) MEXSUFFIX=$(MEXSUFFIX) MEXFLAGS="$(MEXFLAGS)" \
	CXX="$(CXX)" CC="$(CC)" CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" \
	GMP_LD="$(GMP_LD)"

.PHONY: all check-env doc clean distclean

all: check-env
	cd +braidlab/private; $(MAKEMEX) all
	cd +braidlab/+util; $(MAKEMEX) all
	cd +braidlab/@braid/private; $(MAKEMEX) all
	cd +braidlab/@loop/private; $(MAKEMEX) all
	cd +braidlab/@cfbraid/private; $(MAKEMEX) all

check-env:
ifndef MEXSUFFIX
	$(error Unknown system/architecture $(SYS)/$(ARCH))
endif

doc:
	cd doc; make

# remove MEX files and object files.
clean:
	cd extern/cbraid/lib; make clean
	cd extern/trains; make clean
	cd +braidlab/@braid/private; make clean
	cd +braidlab/@loop/private; make clean
	cd +braidlab/@cfbraid/private; make clean
	cd +braidlab/private; make clean
	cd +braidlab/+util; make clean
	cd doc; make clean

# distclean also removes the libraries (useful for recompiling on
# different OS) and the LaTeX-generated files.
distclean: clean
	rm -f extern/cbraid/lib/libcbraid-mex.a
	cd extern/trains; make distclean
	cd doc; make distclean

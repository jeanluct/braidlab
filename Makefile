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
        # MATLAB uses mexa64 for ARM64 Linux (same suffix as x86_64).
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

# Use BRAIDLAB_USE_GMP=0 on command line to disable GMP if desired.
# If BRAIDLAB_USE_GMP is not set, try to detect available GMP libraries
# and disable GMP automatically when they are not present. This avoids
# failing the build on systems without libgmp / libgmpxx installed.
ifndef BRAIDLAB_USE_GMP
# Test by attempting to link a tiny program against gmpxx and gmp.
# Use a one-line shell command that pipes source to the compiler to avoid.
GMP_CHECK := $(shell printf 'int main(void){return 0;}' \
    | $(CC) -x c - -lgmpxx -lgmp -o /tmp/_gmp_check 2>/dev/null \
    && echo yes || echo no; rm -f /tmp/_gmp_check)
ifeq ($(GMP_CHECK),yes)
    BRAIDLAB_USE_GMP = 1
else
    BRAIDLAB_USE_GMP = 0
    $(info GMP libraries not found; building without GMP support.)
endif
endif

ifneq ($(BRAIDLAB_USE_GMP), 0)
    # If Homebrew installed gmp, prefer its lib/include paths.
    # Not guarded by Darwin: also supports Homebrew on Linux.
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

MAKEMEX_ARGS = MEX=$(MEX) MEXSUFFIX=$(MEXSUFFIX) MEXFLAGS="$(MEXFLAGS)" \
    CXX="$(CXX)" CC="$(CC)" CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" \
    GMP_LD="$(GMP_LD)"

# Sub-directory targets for parallel-safe builds with make -j.
# Dependencies: @braid/private and @cfbraid/private both rebuild
# libcbraid-mex.a, so they must not run concurrently.  The other three
# sub-directories are independent and can build in parallel.
SUBDIRS_INDEPENDENT = +braidlab/private +braidlab/+util +braidlab/@loop/private
SUBDIRS_CBRAID      = +braidlab/@cfbraid/private +braidlab/@braid/private

.PHONY: all check-env doc clean distclean \
	$(SUBDIRS_INDEPENDENT) $(SUBDIRS_CBRAID)

all: check-env $(SUBDIRS_INDEPENDENT) $(SUBDIRS_CBRAID)

# Independent sub-directories (safe to build in parallel).
$(SUBDIRS_INDEPENDENT):
	$(MAKE) -C $@ $(MAKEMEX_ARGS) all

# cbraid-dependent sub-directories must be serialized to avoid
# concurrent libcbraid-mex.a rebuilds.
# Force ordering: @cfbraid builds before @braid (arbitrary choice).
+braidlab/@braid/private: +braidlab/@cfbraid/private
$(SUBDIRS_CBRAID):
	$(MAKE) -C $@ $(MAKEMEX_ARGS) all

check-env:
ifndef MEXSUFFIX
	$(error Unsupported system/architecture: $(SYS)/$(ARCH). \
		Supported: Linux (x86_64, aarch64, i686), \
		Darwin (x86_64, arm64), Windows/MINGW/MSYS/Cygwin (x86_64, x86))
endif

doc:
	$(MAKE) -C doc

# remove MEX files and object files.
clean:
	$(MAKE) -C extern/cbraid/lib clean
	$(MAKE) -C extern/trains clean
	$(MAKE) -C +braidlab/@braid/private clean
	$(MAKE) -C +braidlab/@loop/private clean
	$(MAKE) -C +braidlab/@cfbraid/private clean
	$(MAKE) -C +braidlab/private clean
	$(MAKE) -C +braidlab/+util clean
	$(MAKE) -C doc clean

# distclean also removes the libraries (useful for recompiling on
# different OS) and the LaTeX-generated files.
distclean: clean
	rm -f extern/cbraid/lib/libcbraid-mex.a
	$(MAKE) -C extern/trains distclean
	$(MAKE) -C doc distclean

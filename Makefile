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

# Detect the MEX file suffix by compiling a tiny test program with mex
# and inspecting the output file extension.  This replaces the old
# manual uname-based detection table and works on every platform that
# MATLAB supports.
SYS = $(shell uname -s)

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
MEX_CHECK := $(shell command -v $(MEX))
ifndef MEX_CHECK
    $(error $(MEX) not found in PATH.  Set MEX variable with full path or add $(MEX) to PATH)
endif

# Auto-detect MEXSUFFIX by compiling a trivial MEX file and extracting
# the file extension.  The whole sequence runs in a single $(shell ...)
# so the result is available as a Make variable at parse time.
MEX_TMP = /tmp/_mex_tmp
MEXSUFFIX := $(shell \
    echo 'void mexFunction(int a,void*b,int c,const void*d){}' > $(MEX_TMP).c && \
    $(MEX) $(MEX_TMP).c -output $(MEX_TMP) >/dev/null 2>&1 && \
    f=$$(ls $(MEX_TMP).mex* 2>/dev/null) && \
    echo "$${f##*.}" ; \
    rm -f $(MEX_TMP).*)

export MEXSUFFIX

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
# Use a one-line shell command that pipes source to the compiler.
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

.PHONY: all doc clean distclean \
	$(SUBDIRS_INDEPENDENT) $(SUBDIRS_CBRAID)

all: $(SUBDIRS_INDEPENDENT) $(SUBDIRS_CBRAID)

# Independent sub-directories (safe to build in parallel).
$(SUBDIRS_INDEPENDENT):
	$(MAKE) -C $@ $(MAKEMEX_ARGS) all

# cbraid-dependent sub-directories must be serialized to avoid
# concurrent libcbraid-mex.a rebuilds.
# Force ordering: @cfbraid builds before @braid (arbitrary choice).
+braidlab/@braid/private: +braidlab/@cfbraid/private
$(SUBDIRS_CBRAID):
	$(MAKE) -C $@ $(MAKEMEX_ARGS) all

ifndef MEXSUFFIX
    $(error Could not detect MEX suffix.  Is mex in your PATH?)
endif
$(info MEXSUFFIX is $(MEXSUFFIX).)

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

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

# Compatibility wrapper around the CMake build.
#
# This preserves the old top-level workflow shape (`make`, `make install`,
# `make clean`, `make distclean`) while delegating all build logic to CMake.

CMAKE ?= cmake
BUILD_DIR ?= build
PREFIX ?= .

# Best-effort parallelism for CMake-backed builds.
NPROC := $(shell command -v nproc >/dev/null 2>&1 && nproc || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)

.PHONY: all configure install clean distclean doc

all: configure
	MAKEFLAGS= $(CMAKE) --build $(BUILD_DIR) --parallel $(NPROC)

configure:
	$(CMAKE) -S . -B $(BUILD_DIR)

install: configure
	MAKEFLAGS= $(CMAKE) --build $(BUILD_DIR) --parallel $(NPROC)
	$(CMAKE) --install $(BUILD_DIR) --prefix $(PREFIX)

clean:
ifneq ("$(wildcard $(BUILD_DIR))","")
	MAKEFLAGS= $(CMAKE) --build $(BUILD_DIR) --target clean
endif
	+$(MAKE) -C doc clean

distclean:
	# This removes build trees and generated doc output, but does not
	# remove binaries previously installed via `make install -- PREFIX=...`.
	# A fresh CMake configure/build still starts from scratch after distclean.
	rm -rf $(BUILD_DIR) CMakeCache.txt CMakeFiles
	+$(MAKE) -C doc distclean

doc:
	+$(MAKE) -C doc

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

# Packaging install rules for braidlab.
#
# This module owns the install() rules that copy non-build assets
# (MATLAB sources, the bundled VPI library, runnable examples) into
# the staged install tree so that adding the staging root to the
# MATLAB path yields a directly usable braidlab installation.
#
# It does NOT own:
#   - MEX target install rules (handled by braidlab_add_mex in the
#     main CMakeLists.txt, since they are coupled to target creation).
#   - Bundled-GMP install rules (see cmake/BraidlabBundledGMP.cmake).

# Install MATLAB source files so staged artifacts are directly usable after
# adding the staging root to MATLAB path.
install(
  DIRECTORY "${CMAKE_SOURCE_DIR}/+braidlab/"
  DESTINATION "+braidlab"
  FILES_MATCHING
    PATTERN "*.m"
    PATTERN "*.mat"
)

# Bundle the Variable Precision Integers (VPI) library so that
# braidlab.util.checkvpi can locate it at runtime in the binary
# distribution.  VPI is pure MATLAB code (John D'Errico, FEX 22725)
# used as the .m-layer arbitrary-precision integer type for loop
# coordinates (see loop.loop, braid.loopcoords).
install(
  DIRECTORY "${CMAKE_SOURCE_DIR}/extern/VariablePrecisionIntegers"
  DESTINATION "extern"
  PATTERN "*.asv" EXCLUDE
)

# Bundle runnable user-facing examples.  The taffy testcase depends on
# examples/taffy.m (which itself uses examples/arrow.m).
install(
  DIRECTORY "${CMAKE_SOURCE_DIR}/examples"
  DESTINATION "."
  FILES_MATCHING PATTERN "*.m"
)

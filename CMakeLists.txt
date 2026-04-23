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

cmake_minimum_required(VERSION 3.20)

project(braidlab LANGUAGES C CXX)

# Match the Makefile workflow's optimized default build behavior.
# On single-config generators (e.g., Ninja/Unix Makefiles), an empty
# CMAKE_BUILD_TYPE means no optimization flags, which can slow the MEX tests.
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(BRAIDLAB_USE_GMP "Enable GMP-backed code paths when libraries are found" ON)
option(BRAIDLAB_BUILD_DOCS "Enable braidlab-doc target" OFF)

set(BRAIDLAB_DIR_BRAID_PRIVATE "+braidlab/@braid/private")
set(BRAIDLAB_DIR_CFBRAID_PRIVATE "+braidlab/@cfbraid/private")
set(BRAIDLAB_DIR_LOOP_PRIVATE "+braidlab/@loop/private")
set(BRAIDLAB_DIR_PRIVATE "+braidlab/private")
set(BRAIDLAB_DIR_UTIL "+braidlab/+util")

# MATLAB's CMake module provides matlab_add_mex and MEX compiler discovery.
find_package(Matlab REQUIRED COMPONENTS MEX_COMPILER)

# Helper to define a MEX target and install it into the expected
# +braidlab package-relative destination.
function(braidlab_add_mex target source install_dir)
  set(options)
  set(one_value_args OUTPUT_NAME)
  set(multi_value_args INCLUDE_DIRS LINK_LIBS COMPILE_DEFINITIONS)
  cmake_parse_arguments(BLM "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  if(NOT BLM_OUTPUT_NAME)
    set(BLM_OUTPUT_NAME "${target}")
  endif()

  matlab_add_mex(NAME ${target} SRC ${source} OUTPUT_NAME ${BLM_OUTPUT_NAME})

  if(BLM_INCLUDE_DIRS)
    target_include_directories(${target} PRIVATE ${BLM_INCLUDE_DIRS})
  endif()

  if(BLM_LINK_LIBS)
    target_link_libraries(${target} ${BLM_LINK_LIBS})
  endif()

  if(BLM_COMPILE_DEFINITIONS)
    target_compile_definitions(${target} PRIVATE ${BLM_COMPILE_DEFINITIONS})
  endif()

  set_target_properties(${target} PROPERTIES
    PREFIX ""
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${install_dir}"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${install_dir}"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${install_dir}"
  )

  install(TARGETS ${target}
    LIBRARY DESTINATION "${install_dir}"
    RUNTIME DESTINATION "${install_dir}"
  )
endfunction()

# Convenience wrapper that takes a source path relative to repository root.
function(braidlab_add_mex_rel target relative_source install_dir)
  braidlab_add_mex(${target} "${CMAKE_SOURCE_DIR}/${relative_source}" "${install_dir}" ${ARGN})
endfunction()

set(CBRAID_SOURCES
  extern/cbraid/lib/cbraid.cpp
  extern/cbraid/lib/braiding.cpp
)

add_library(cbraid_mex STATIC ${CBRAID_SOURCES})
target_include_directories(cbraid_mex PUBLIC "${CMAKE_SOURCE_DIR}/extern/cbraid/include")

# Toby Hall's trains sources are compiled directly into a static library used
# by train_helper.
set(TRAINS_SOURCES
  extern/trains/src/Batch.cpp
  extern/trains/src/braid.cpp
  extern/trains/src/edgevert.cpp
  extern/trains/src/embedding.cpp
  extern/trains/src/General.cpp
  extern/trains/src/Graphalg.cpp
  extern/trains/src/graph.cpp
  extern/trains/src/Graphset.cpp
  extern/trains/src/Graputil.cpp
  extern/trains/src/help.cpp
  extern/trains/src/hshoe.cpp
  extern/trains/src/Matrix.cpp
  extern/trains/src/ttt.cpp
)

add_library(trains STATIC ${TRAINS_SOURCES})
target_include_directories(trains PUBLIC "${CMAKE_SOURCE_DIR}/extern/trains")

set(BRAIDLAB_GMP_LINK_LIBS)
set(BRAIDLAB_GMP_DEFINITIONS)
# Keep behavior aligned with the Makefiles: enable GMP-dependent code paths
# only when both gmp and gmpxx are available.
if(BRAIDLAB_USE_GMP)
  find_library(BRAIDLAB_GMP_LIBRARY NAMES gmp)
  find_library(BRAIDLAB_GMPXX_LIBRARY NAMES gmpxx)
  if(BRAIDLAB_GMP_LIBRARY AND BRAIDLAB_GMPXX_LIBRARY)
    list(APPEND BRAIDLAB_GMP_LINK_LIBS "${BRAIDLAB_GMPXX_LIBRARY}" "${BRAIDLAB_GMP_LIBRARY}")
    list(APPEND BRAIDLAB_GMP_DEFINITIONS BRAIDLAB_USE_GMP)
    message(STATUS "GMP enabled")
  else()
    message(WARNING "GMP libraries not found; building without BRAIDLAB_USE_GMP")
  endif()
else()
  message(STATUS "GMP support disabled by BRAIDLAB_USE_GMP=OFF")
endif()

braidlab_add_mex_rel(randomwalk_helper
  "+braidlab/private/randomwalk_helper.cpp"
  "${BRAIDLAB_DIR_PRIVATE}"
)

braidlab_add_mex_rel(assignmentoptimal
  "extern/assignmentoptimal/assignmentoptimal.c"
  "${BRAIDLAB_DIR_UTIL}"
)

braidlab_add_mex_rel(looplist_helper
  "+braidlab/@loop/private/looplist_helper.c"
  "${BRAIDLAB_DIR_LOOP_PRIVATE}"
)
braidlab_add_mex_rel(intersec_helper
  "+braidlab/@loop/private/intersec_helper.cpp"
  "${BRAIDLAB_DIR_LOOP_PRIVATE}"
)
braidlab_add_mex_rel(length_helper
  "+braidlab/@loop/private/length_helper.cpp"
  "${BRAIDLAB_DIR_LOOP_PRIVATE}"
)

set(CBRAID_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/extern/cbraid/include")

# MEX targets that depend on cbraid headers and static library.
braidlab_add_mex_rel(cfbraid_helper
  "+braidlab/@cfbraid/private/cfbraid_helper.cpp"
  "${BRAIDLAB_DIR_CFBRAID_PRIVATE}"
  INCLUDE_DIRS "${CBRAID_INCLUDE_DIR}"
  LINK_LIBS cbraid_mex
)
braidlab_add_mex_rel(conjtest_helper
  "+braidlab/@cfbraid/private/conjtest_helper.cpp"
  "${BRAIDLAB_DIR_CFBRAID_PRIVATE}"
  INCLUDE_DIRS "${CBRAID_INCLUDE_DIR}"
  LINK_LIBS cbraid_mex
)

braidlab_add_mex_rel(compact_helper
  "+braidlab/@braid/private/compact_helper.cpp"
  "${BRAIDLAB_DIR_BRAID_PRIVATE}"
  INCLUDE_DIRS "${CBRAID_INCLUDE_DIR}"
  LINK_LIBS cbraid_mex
)
braidlab_add_mex_rel(subbraid_helper
  "+braidlab/@braid/private/subbraid_helper.cpp"
  "${BRAIDLAB_DIR_BRAID_PRIVATE}"
  INCLUDE_DIRS "${CBRAID_INCLUDE_DIR}"
  LINK_LIBS cbraid_mex
)
braidlab_add_mex_rel(train_helper
  "+braidlab/@braid/private/train_helper.cpp"
  "${BRAIDLAB_DIR_BRAID_PRIVATE}"
  INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/extern/trains"
  LINK_LIBS trains
)
braidlab_add_mex_rel(cross2gen_helper
  "+braidlab/@braid/private/cross2gen_helper.cpp"
  "${BRAIDLAB_DIR_BRAID_PRIVATE}"
  LINK_LIBS ${BRAIDLAB_GMP_LINK_LIBS}
  COMPILE_DEFINITIONS ${BRAIDLAB_GMP_DEFINITIONS}
)
braidlab_add_mex_rel(loopsigma_helper
  "+braidlab/@braid/private/loopsigma_helper.cpp"
  "${BRAIDLAB_DIR_BRAID_PRIVATE}"
  LINK_LIBS ${BRAIDLAB_GMP_LINK_LIBS}
  COMPILE_DEFINITIONS ${BRAIDLAB_GMP_DEFINITIONS}
)
braidlab_add_mex_rel(entropy_helper
  "+braidlab/@braid/private/entropy_helper.cpp"
  "${BRAIDLAB_DIR_BRAID_PRIVATE}"
  INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/${BRAIDLAB_DIR_LOOP_PRIVATE}"
  LINK_LIBS ${BRAIDLAB_GMP_LINK_LIBS}
  COMPILE_DEFINITIONS ${BRAIDLAB_GMP_DEFINITIONS}
)

if(BRAIDLAB_BUILD_DOCS)
  find_program(BRAIDLAB_MAKE_EXECUTABLE NAMES gmake make)
  if(NOT BRAIDLAB_MAKE_EXECUTABLE)
    message(FATAL_ERROR "BRAIDLAB_BUILD_DOCS=ON but make was not found")
  endif()

  # Delegate documentation build to existing doc/Makefile to preserve
  # current release/version behavior.
  add_custom_target(braidlab-doc
    COMMAND "${BRAIDLAB_MAKE_EXECUTABLE}" -C "${CMAKE_SOURCE_DIR}/doc" braidlab_guide.pdf
    COMMENT "Building braidlab_guide.pdf"
    VERBATIM
  )
endif()

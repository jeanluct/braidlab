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

# Oldest macOS the MEX files will load on.  Without this, the compiler
# targets the build machine's own macOS version, so packages built on a
# new runner would not load on older (but MATLAB-supported) macOS.  13.0
# covers every macOS that MATLAB R2024b supports (13.7, 14, 15).  Must be
# set before project(); an explicit -DCMAKE_OSX_DEPLOYMENT_TARGET or the
# MACOSX_DEPLOYMENT_TARGET environment variable takes precedence.
if(CMAKE_HOST_APPLE AND NOT DEFINED CMAKE_OSX_DEPLOYMENT_TARGET
    AND NOT DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
  set(CMAKE_OSX_DEPLOYMENT_TARGET "13.0" CACHE STRING
    "Minimum macOS version for the MEX files")
endif()

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

# GMP linkage policy (issue #165).  Values:
#   system  - link against system GMP; copy nothing.  Default; used by
#             local developer builds.
#   static  - statically link libgmp/libgmpxx into the MEX files, so
#             they have no GMP runtime dependency at all.  Used by CI
#             release jobs.  Needs static, position-independent GMP
#             libraries (see .github/scripts/build-gmp-static.sh, or
#             vcpkg's x64-windows-static-md triplet on Windows).  GMP is
#             used under the GPLv3 option of its LGPLv3/GPLv2+ dual
#             license, and its license texts are installed alongside.
#   off     - build without GMP support (equivalent to BRAIDLAB_USE_GMP=OFF).
# (A former 'bundled' mode, which shipped GMP shared libraries next to the
# MEX files, was removed in 3.4.2 in favor of 'static'.)
# BRAIDLAB_USE_GMP is retained as a backward-compatible alias: when
# BRAIDLAB_GMP_LINKAGE is left at its default and BRAIDLAB_USE_GMP=OFF
# is passed, BRAIDLAB_GMP_LINKAGE is forced to off.
set(BRAIDLAB_GMP_LINKAGE "system" CACHE STRING
  "GMP linkage policy: system, static, or off")
set_property(CACHE BRAIDLAB_GMP_LINKAGE PROPERTY STRINGS system static off)

if(NOT BRAIDLAB_USE_GMP AND BRAIDLAB_GMP_LINKAGE STREQUAL "system")
  set(BRAIDLAB_GMP_LINKAGE "off" CACHE STRING
    "GMP linkage policy: system, static, or off" FORCE)
  message(STATUS "BRAIDLAB_USE_GMP=OFF -> BRAIDLAB_GMP_LINKAGE=off")
endif()

if(BRAIDLAB_GMP_LINKAGE STREQUAL "bundled")
  message(FATAL_ERROR
    "BRAIDLAB_GMP_LINKAGE=bundled was removed in braidlab 3.4.2.  "
    "Use 'static' for self-contained packages (see "
    ".github/scripts/build-gmp-static.sh), or 'system'.")
endif()

if(NOT BRAIDLAB_GMP_LINKAGE MATCHES "^(system|static|off)$")
  message(FATAL_ERROR
    "BRAIDLAB_GMP_LINKAGE='${BRAIDLAB_GMP_LINKAGE}' is invalid; "
    "expected one of: system, static, off.")
endif()

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

  # Force legacy MEX API mode so generated binaries do not depend on
  # C++ Data API/Engine runtime libraries that are not consistently present
  # across GitHub-hosted MATLAB installations (notably macOS arm64).
  # Also disable implicit MATLAB library linkage and link explicitly to
  # mex/mx so MEX targets do not accidentally pick up Engine/DataArray libs.
  matlab_add_mex(
    NAME ${target}
    SRC ${source}
    OUTPUT_NAME ${BLM_OUTPUT_NAME}
    R2017b
    NO_IMPLICIT_LINK_TO_MATLAB_LIBRARIES
  )

  # On macOS, export exactly the two symbols a C-API MEX file defines.
  # matlab_add_mex exports MATLAB's C++ MEX API entry points too
  # (_mexCreateMexFunction etc., via cppMexFunction.map) even for C-API
  # MEX files, and relies on -Wl,-U to excuse their absence.  The Xcode 26
  # linker rejects that ("Undefined symbols ... <initial-undefines>"), and
  # older linkers left dangling re-exports in the binaries.  Replacing the
  # link flags wholesale is safe: on Apple, matlab_add_mex puts nothing
  # else in LINK_FLAGS.
  if(APPLE)
    set_property(TARGET ${target} PROPERTY LINK_FLAGS
      "-Wl,-exported_symbols_list,${CMAKE_SOURCE_DIR}/cmake/mex-exports-macos.txt")
  endif()

  # Link to MATLAB's MEX runtime libraries.  On Linux we cannot use
  # the imported targets Matlab::mex / Matlab::mx directly: their
  # IMPORTED_LOCATION is an absolute path (e.g.
  # /opt/hostedtoolcache/MATLAB/<ver>/x64/bin/glnxa64/libmex.so) and
  # libmex.so / libmx.so do not declare a SONAME, so the linker
  # records the full absolute path verbatim in DT_NEEDED.  That path
  # is then baked into every shipped MEX file and only resolves on
  # the exact machine that built it; users hit
  #   "Invalid MEX-file '...': /opt/.../libmex.so: cannot open shared
  #    object file: No such file or directory"
  # The pre-CMake build used the mex script, which links via
  # -L<dir> -lmex -lmx and records bare basenames in DT_NEEDED;
  # MATLAB's loader then injects matlabroot/bin/glnxa64 into the
  # search path at MEX-load time and the basenames resolve correctly.
  # We reproduce that behaviour with -l:libmex.so / -l:libmx.so
  # (GNU ld syntax that forces an exact-name lookup and records the
  # file's name, not its path, in DT_NEEDED).
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    get_target_property(_braidlab_libmex_path Matlab::mex IMPORTED_LOCATION)
    get_filename_component(_braidlab_matlab_libdir "${_braidlab_libmex_path}" DIRECTORY)
    # -Wl,--no-as-needed forces DT_NEEDED entries to be retained even
    # when the linker thinks the library is unused (mexFunction is
    # called from MATLAB via dlsym, so the linker cannot see the
    # API references).  -l:libNAME.so records the bare basename in
    # DT_NEEDED instead of the absolute path that find_library
    # returned.
    target_link_options(${target} PRIVATE
      "-L${_braidlab_matlab_libdir}"
      "-Wl,--no-as-needed"
      "-l:libmex.so"
      "-l:libmx.so"
      "-Wl,--as-needed")
  else()
    target_link_libraries(${target} Matlab::mex Matlab::mx)
  endif()

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

# Packaging install rules for non-MEX assets (.m sources, VPI, examples).
# See cmake/BraidlabPackage.cmake for the rationale.
include(cmake/BraidlabPackage.cmake)

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
set(BRAIDLAB_GMP_INCLUDE_DIRS)
# Locate GMP/GMPXX for the system and static linkage modes.  A missing
# GMP is a hard error in those modes, with per-OS install hints.
if(NOT BRAIDLAB_GMP_LINKAGE STREQUAL "off")
  # For static linkage, ask for the archives explicitly: find_library
  # would otherwise prefer a shared libgmp found on the same path.  On
  # Windows a static .lib and an import .lib share a name, so there the
  # choice is made by the vcpkg triplet (x64-windows-static-md).
  if(BRAIDLAB_GMP_LINKAGE STREQUAL "static" AND NOT WIN32)
    set(_braidlab_gmp_names libgmp.a)
    set(_braidlab_gmpxx_names libgmpxx.a)
  else()
    set(_braidlab_gmp_names gmp)
    set(_braidlab_gmpxx_names gmpxx)
  endif()
  find_path(BRAIDLAB_GMP_INCLUDE_DIR NAMES gmp.h)
  find_path(BRAIDLAB_GMPXX_INCLUDE_DIR NAMES gmpxx.h)
  find_library(BRAIDLAB_GMP_LIBRARY NAMES ${_braidlab_gmp_names})
  find_library(BRAIDLAB_GMPXX_LIBRARY NAMES ${_braidlab_gmpxx_names})

  # vcpkg's toolchain file puts its debug tree first whenever
  # CMAKE_BUILD_TYPE is undefined, which it is under the multi-config
  # Visual Studio generator.  Debug GMP links against Microsoft's debug C
  # runtime, which exists only where Visual Studio is installed, so
  # braidlab 3.4 shipped GMP DLLs that fail to load on ordinary machines.
  # Refuse to build that way; configure with -DCMAKE_BUILD_TYPE=Release.
  if(WIN32)
    foreach(_braidlab_lib IN ITEMS "${BRAIDLAB_GMP_LIBRARY}" "${BRAIDLAB_GMPXX_LIBRARY}")
      if(_braidlab_lib MATCHES "/debug/")
        message(FATAL_ERROR
          "GMP resolved to a debug build (${_braidlab_lib}).  Its DLLs "
          "need the Visual Studio debug runtime.  Configure with "
          "-DCMAKE_BUILD_TYPE=Release so vcpkg selects release libraries.")
      endif()
    endforeach()
  endif()

  if(BRAIDLAB_GMP_INCLUDE_DIR AND BRAIDLAB_GMPXX_INCLUDE_DIR
     AND BRAIDLAB_GMP_LIBRARY AND BRAIDLAB_GMPXX_LIBRARY)
    list(APPEND BRAIDLAB_GMP_INCLUDE_DIRS "${BRAIDLAB_GMP_INCLUDE_DIR}" "${BRAIDLAB_GMPXX_INCLUDE_DIR}")
    list(REMOVE_DUPLICATES BRAIDLAB_GMP_INCLUDE_DIRS)
    list(APPEND BRAIDLAB_GMP_LINK_LIBS "${BRAIDLAB_GMPXX_LIBRARY}" "${BRAIDLAB_GMP_LIBRARY}")
    if(BRAIDLAB_GMP_LINKAGE STREQUAL "static" AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
      # Keep GMP's symbols private to each MEX file, so they can never
      # bind to the libgmp.so that MATLAB itself loads (via gnutls).
      list(APPEND BRAIDLAB_GMP_LINK_LIBS "-Wl,--exclude-libs,libgmp.a:libgmpxx.a")
    endif()
    list(APPEND BRAIDLAB_GMP_DEFINITIONS BRAIDLAB_USE_GMP)
    message(STATUS "GMP enabled (BRAIDLAB_GMP_LINKAGE=${BRAIDLAB_GMP_LINKAGE})")
  else()
    message(FATAL_ERROR
      "GMP/GMPXX not found but BRAIDLAB_GMP_LINKAGE=${BRAIDLAB_GMP_LINKAGE} requires them.\n"
      "Install GMP and rerun CMake, or pass -DBRAIDLAB_GMP_LINKAGE=off to disable GMP.\n"
      "Hints:\n"
      "  Debian/Ubuntu: sudo apt-get install libgmp-dev libgmpxx4ldbl libgmp10\n"
      "  Fedora/RHEL:   sudo dnf install gmp-devel gmp-c++\n"
      "  macOS:         brew install gmp\n"
      "  Windows:       vcpkg install gmp:x64-windows  (or MSYS2: pacman -S mingw-w64-x86_64-gmp)")
  endif()
else()
  message(STATUS "GMP support disabled (BRAIDLAB_GMP_LINKAGE=off)")
endif()

braidlab_add_mex_rel(randomwalk_helper
  "+braidlab/private/randomwalk_helper.cpp"
  "${BRAIDLAB_DIR_PRIVATE}"
)
if(MSVC)
  target_compile_definitions(randomwalk_helper PRIVATE _USE_MATH_DEFINES)
endif()

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
  INCLUDE_DIRS ${BRAIDLAB_GMP_INCLUDE_DIRS}
  LINK_LIBS ${BRAIDLAB_GMP_LINK_LIBS}
  COMPILE_DEFINITIONS ${BRAIDLAB_GMP_DEFINITIONS}
)
braidlab_add_mex_rel(loopsigma_helper
  "+braidlab/@braid/private/loopsigma_helper.cpp"
  "${BRAIDLAB_DIR_BRAID_PRIVATE}"
  INCLUDE_DIRS ${BRAIDLAB_GMP_INCLUDE_DIRS}
  LINK_LIBS ${BRAIDLAB_GMP_LINK_LIBS}
  COMPILE_DEFINITIONS ${BRAIDLAB_GMP_DEFINITIONS}
)
braidlab_add_mex_rel(entropy_helper
  "+braidlab/@braid/private/entropy_helper.cpp"
  "${BRAIDLAB_DIR_BRAID_PRIVATE}"
  INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/${BRAIDLAB_DIR_LOOP_PRIVATE}" ${BRAIDLAB_GMP_INCLUDE_DIRS}
  LINK_LIBS ${BRAIDLAB_GMP_LINK_LIBS}
  COMPILE_DEFINITIONS ${BRAIDLAB_GMP_DEFINITIONS}
)

# Static GMP: ship GMP's license texts and a README in extern/gmp/.
# This is a license obligation, so a missing license is an error.  The
# texts come either from .github/scripts/build-gmp-static.sh
# (<prefix>/share/licenses/gmp) or from vcpkg (<prefix>/share/gmp).
if(BRAIDLAB_GMP_LINKAGE STREQUAL "static")
  get_filename_component(_braidlab_gmp_libdir "${BRAIDLAB_GMP_LIBRARY}" DIRECTORY)
  get_filename_component(_braidlab_gmp_prefix "${_braidlab_gmp_libdir}" DIRECTORY)
  file(GLOB _braidlab_gmp_licenses
    "${_braidlab_gmp_prefix}/share/licenses/gmp/COPYING*"
    "${_braidlab_gmp_prefix}/share/gmp/copyright")
  if(NOT _braidlab_gmp_licenses)
    message(FATAL_ERROR
      "BRAIDLAB_GMP_LINKAGE=static: no GMP license texts found under "
      "${_braidlab_gmp_prefix}/share.  Build GMP with "
      ".github/scripts/build-gmp-static.sh, or use vcpkg.")
  endif()
  install(FILES ${_braidlab_gmp_licenses} "${CMAKE_SOURCE_DIR}/extern/gmp/README.md"
    DESTINATION extern/gmp)
endif()

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

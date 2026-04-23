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

# GMP linkage policy (issue #165).  Values:
#   system  - link against system GMP; copy nothing.  Default; used by
#             local developer builds.
#   bundled - link against system GMP; install the resolved GMP runtime
#             libraries alongside the GMP-using MEX files and adjust
#             rpath/install-name so MEX files load them locally.  Used
#             by CI release jobs to produce self-contained archives.
#   static  - statically link libgmp/libgmpxx.  Reserved for future use;
#             not implemented in Phase A.
#   off     - build without GMP support (equivalent to BRAIDLAB_USE_GMP=OFF).
# BRAIDLAB_USE_GMP is retained as a backward-compatible alias: when
# BRAIDLAB_GMP_LINKAGE is left at its default and BRAIDLAB_USE_GMP=OFF
# is passed, BRAIDLAB_GMP_LINKAGE is forced to off.
set(BRAIDLAB_GMP_LINKAGE "system" CACHE STRING
  "GMP linkage policy: system, bundled, static, or off")
set_property(CACHE BRAIDLAB_GMP_LINKAGE PROPERTY STRINGS system bundled static off)

if(NOT BRAIDLAB_USE_GMP AND BRAIDLAB_GMP_LINKAGE STREQUAL "system")
  set(BRAIDLAB_GMP_LINKAGE "off" CACHE STRING
    "GMP linkage policy: system, bundled, static, or off" FORCE)
  message(STATUS "BRAIDLAB_USE_GMP=OFF -> BRAIDLAB_GMP_LINKAGE=off")
endif()

if(NOT BRAIDLAB_GMP_LINKAGE MATCHES "^(system|bundled|static|off)$")
  message(FATAL_ERROR
    "BRAIDLAB_GMP_LINKAGE='${BRAIDLAB_GMP_LINKAGE}' is invalid; "
    "expected one of: system, bundled, static, off.")
endif()

if(BRAIDLAB_GMP_LINKAGE STREQUAL "static")
  message(FATAL_ERROR
    "BRAIDLAB_GMP_LINKAGE=static is not implemented yet.  "
    "Use 'system' (default) or 'bundled', or 'off' to disable GMP.")
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

  target_link_libraries(${target} Matlab::mex Matlab::mx)

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

# Install MATLAB source files so staged artifacts are directly usable after
# adding the staging root to MATLAB path.
install(
  DIRECTORY "${CMAKE_SOURCE_DIR}/+braidlab/"
  DESTINATION "+braidlab"
  FILES_MATCHING
    PATTERN "*.m"
    PATTERN "*.mat"
)

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
set(BRAIDLAB_GMP_BUNDLE_FILES)
# Locate GMP/GMPXX for system and bundled linkage modes.  A missing
# GMP is now a hard error in those modes (replacing the previous
# silent fallback to OFF), with per-OS install hints.
if(BRAIDLAB_GMP_LINKAGE STREQUAL "system" OR BRAIDLAB_GMP_LINKAGE STREQUAL "bundled")
  find_path(BRAIDLAB_GMP_INCLUDE_DIR NAMES gmp.h)
  find_path(BRAIDLAB_GMPXX_INCLUDE_DIR NAMES gmpxx.h)
  find_library(BRAIDLAB_GMP_LIBRARY NAMES gmp)
  find_library(BRAIDLAB_GMPXX_LIBRARY NAMES gmpxx)

  if(BRAIDLAB_GMP_INCLUDE_DIR AND BRAIDLAB_GMPXX_INCLUDE_DIR
     AND BRAIDLAB_GMP_LIBRARY AND BRAIDLAB_GMPXX_LIBRARY)
    list(APPEND BRAIDLAB_GMP_INCLUDE_DIRS "${BRAIDLAB_GMP_INCLUDE_DIR}" "${BRAIDLAB_GMPXX_INCLUDE_DIR}")
    list(REMOVE_DUPLICATES BRAIDLAB_GMP_INCLUDE_DIRS)
    list(APPEND BRAIDLAB_GMP_LINK_LIBS "${BRAIDLAB_GMPXX_LIBRARY}" "${BRAIDLAB_GMP_LIBRARY}")
    list(APPEND BRAIDLAB_GMP_DEFINITIONS BRAIDLAB_USE_GMP)
    message(STATUS "GMP enabled (BRAIDLAB_GMP_LINKAGE=${BRAIDLAB_GMP_LINKAGE})")

    if(BRAIDLAB_GMP_LINKAGE STREQUAL "bundled")
      # Resolve symlink chains so install copies the versioned files
      # (e.g. libgmp.so.10.4.1) rather than the unversioned linker
      # symlink (libgmp.so), which would not be loadable on its own.
      get_filename_component(BRAIDLAB_GMP_LIBRARY_REAL
        "${BRAIDLAB_GMP_LIBRARY}" REALPATH)
      get_filename_component(BRAIDLAB_GMPXX_LIBRARY_REAL
        "${BRAIDLAB_GMPXX_LIBRARY}" REALPATH)
      list(APPEND BRAIDLAB_GMP_BUNDLE_FILES
        "${BRAIDLAB_GMP_LIBRARY_REAL}" "${BRAIDLAB_GMPXX_LIBRARY_REAL}")

      # Determine the SONAME (Linux) or install-name (macOS) so the
      # bundled files are installed under the name the dynamic loader
      # actually requests.  Without this, the realpath name (e.g.
      # libgmp.so.10.5.0) would not match the MEX file's NEEDED entry
      # (libgmp.so.10) and the loader would silently fall back to the
      # system GMP, defeating the purpose of bundling.  Windows DLLs
      # do not have this concern; the realpath name is what is loaded.
      function(_braidlab_resolve_loader_name lib_path out_var)
        if(APPLE)
          execute_process(COMMAND otool -D "${lib_path}"
            OUTPUT_VARIABLE _otool_out OUTPUT_STRIP_TRAILING_WHITESPACE)
          # otool -D output: <path>:\n<install_name>
          string(REGEX REPLACE ".*\n" "" _install_name "${_otool_out}")
          get_filename_component(_loader_name "${_install_name}" NAME)
        elseif(UNIX)
          execute_process(COMMAND objdump -p "${lib_path}"
            OUTPUT_VARIABLE _objdump_out OUTPUT_STRIP_TRAILING_WHITESPACE)
          string(REGEX MATCH "SONAME[ \t]+([^\n\r]+)" _ "${_objdump_out}")
          set(_loader_name "${CMAKE_MATCH_1}")
        else()
          get_filename_component(_loader_name "${lib_path}" NAME)
        endif()
        if(NOT _loader_name)
          message(FATAL_ERROR
            "Could not determine SONAME/install-name for ${lib_path}")
        endif()
        set(${out_var} "${_loader_name}" PARENT_SCOPE)
      endfunction()
      _braidlab_resolve_loader_name(
        "${BRAIDLAB_GMP_LIBRARY_REAL}"   BRAIDLAB_GMP_LOADER_NAME)
      _braidlab_resolve_loader_name(
        "${BRAIDLAB_GMPXX_LIBRARY_REAL}" BRAIDLAB_GMPXX_LOADER_NAME)
      message(STATUS "GMP bundle: ${BRAIDLAB_GMP_LIBRARY_REAL} -> ${BRAIDLAB_GMP_LOADER_NAME}")
      message(STATUS "GMPXX bundle: ${BRAIDLAB_GMPXX_LIBRARY_REAL} -> ${BRAIDLAB_GMPXX_LOADER_NAME}")
    endif()
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

# Bundled-GMP install rules (issue #165, Phase A).
# Active only when BRAIDLAB_GMP_LINKAGE=bundled.  Co-locates the
# resolved GMP runtime libraries with the GMP-using MEX files and
# arranges for the loader to find them at MEX load time without any
# system GMP installed:
#   - Linux: rpath '$ORIGIN' (escaped) on each GMP-using MEX target.
#   - macOS: install_name_tool fix-up on each MEX (and on the bundled
#            libgmpxx, which references libgmp) at install time.
#   - Windows: no fix-up needed; DLL co-location with the MEX is
#              sufficient on the Windows DLL search path.
if(BRAIDLAB_GMP_LINKAGE STREQUAL "bundled")
  set(BRAIDLAB_GMP_MEX_TARGETS cross2gen_helper loopsigma_helper entropy_helper)

  if(UNIX AND NOT APPLE)
    set_target_properties(${BRAIDLAB_GMP_MEX_TARGETS} PROPERTIES
      INSTALL_RPATH "\$ORIGIN"
      INSTALL_RPATH_USE_LINK_PATH OFF
      BUILD_WITH_INSTALL_RPATH OFF
    )
  elseif(APPLE)
    set_target_properties(${BRAIDLAB_GMP_MEX_TARGETS} PROPERTIES
      INSTALL_RPATH "@loader_path"
      INSTALL_RPATH_USE_LINK_PATH OFF
    )
  endif()

  # Install the resolved GMP library files alongside the MEX files,
  # under the SONAME/install-name the loader requests (not the
  # versioned realpath name).  See _braidlab_resolve_loader_name above
  # for the rationale.
  install(FILES "${BRAIDLAB_GMP_LIBRARY_REAL}"
    DESTINATION "${BRAIDLAB_DIR_BRAID_PRIVATE}"
    RENAME "${BRAIDLAB_GMP_LOADER_NAME}"
  )
  install(FILES "${BRAIDLAB_GMPXX_LIBRARY_REAL}"
    DESTINATION "${BRAIDLAB_DIR_BRAID_PRIVATE}"
    RENAME "${BRAIDLAB_GMPXX_LOADER_NAME}"
  )

  # macOS: rewrite install-name references so the MEX files and the
  # bundled libgmpxx resolve GMP via @loader_path.  Done at install
  # time because the MEX files were linked against absolute Homebrew
  # paths and need to be patched in the staged tree, not the build
  # tree.
  if(APPLE)
    install(CODE "
      set(_gmp_dir \"\${CMAKE_INSTALL_PREFIX}/${BRAIDLAB_DIR_BRAID_PRIVATE}\")
      set(_gmp_name \"${BRAIDLAB_GMP_LOADER_NAME}\")
      set(_gmpxx_name \"${BRAIDLAB_GMPXX_LOADER_NAME}\")
      foreach(_mex ${BRAIDLAB_GMP_MEX_TARGETS})
        file(GLOB _mex_files \"\${_gmp_dir}/\${_mex}.mex*\")
        foreach(_mex_file \${_mex_files})
          execute_process(COMMAND install_name_tool
            -change \"${BRAIDLAB_GMP_LIBRARY_REAL}\"   \"@loader_path/\${_gmp_name}\"
            -change \"${BRAIDLAB_GMPXX_LIBRARY_REAL}\" \"@loader_path/\${_gmpxx_name}\"
            \"\${_mex_file}\")
        endforeach()
      endforeach()
      execute_process(COMMAND install_name_tool
        -change \"${BRAIDLAB_GMP_LIBRARY_REAL}\" \"@loader_path/\${_gmp_name}\"
        \"\${_gmp_dir}/\${_gmpxx_name}\")
      execute_process(COMMAND install_name_tool -id \"@loader_path/\${_gmp_name}\"
        \"\${_gmp_dir}/\${_gmp_name}\")
      execute_process(COMMAND install_name_tool -id \"@loader_path/\${_gmpxx_name}\"
        \"\${_gmp_dir}/\${_gmpxx_name}\")
    ")
  endif()
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

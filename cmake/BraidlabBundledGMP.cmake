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

# Bundled-GMP support for braidlab (issue #165, Phase A).
#
# This module is included from CMakeLists.txt only when
# BRAIDLAB_GMP_LINKAGE=bundled.  It is responsible for everything that
# turns the system-resolved GMP libraries into a self-contained
# package: resolving runtime artefact paths and loader names, copying
# the libraries into the staged install tree under the names the
# dynamic loader requests, and patching rpath / install-name so that
# MEX files locate the bundled libraries at load time without any
# system GMP installed.
#
# Inputs (set by the main CMakeLists.txt before include):
#   BRAIDLAB_GMP_LIBRARY     - find_library() result for libgmp.
#   BRAIDLAB_GMPXX_LIBRARY   - find_library() result for libgmpxx.
#   BRAIDLAB_DIR_BRAID_PRIVATE - install destination for GMP-using MEX
#                                files (the +braidlab/@braid/private
#                                package directory).
#
# Targets the module operates on:
#   cross2gen_helper, loopsigma_helper, entropy_helper.  These are
#   declared earlier in CMakeLists.txt; we only adjust their install
#   properties here.
#
# Per-OS strategy:
#   - Linux: rpath '$ORIGIN' (escaped) on each GMP-using MEX target.
#   - macOS: install_name_tool fix-up on each MEX (and on the bundled
#            libgmpxx, which references libgmp) at install time, plus
#            @loader_path rpath on the MEX targets.
#   - Windows: no fix-up needed; DLL co-location with the MEX is
#              sufficient on the Windows DLL search path.
#
# Removability: this module exists so that bundling can be excised in
# the future by deleting this file and the include() block in
# CMakeLists.txt that gates it.  No other call sites should reference
# its internals.

# Resolve symlink chains so install copies the versioned files
# (e.g. libgmp.so.10.4.1) rather than the unversioned linker
# symlink (libgmp.so), which would not be loadable on its own.
get_filename_component(BRAIDLAB_GMP_LIBRARY_REAL
  "${BRAIDLAB_GMP_LIBRARY}" REALPATH)
get_filename_component(BRAIDLAB_GMPXX_LIBRARY_REAL
  "${BRAIDLAB_GMPXX_LIBRARY}" REALPATH)

if(WIN32)
  # find_library on Windows returns the .lib import library
  # (e.g. C:/vcpkg/installed/x64-windows/lib/gmp.lib), but the
  # runtime artefact we need to bundle is the matching .dll
  # (e.g. .../bin/gmp-10.dll).  Locate it by walking up to the
  # vcpkg installation prefix and globbing the bin/ directory
  # for a DLL whose basename starts with the import library's
  # basename.
  function(_braidlab_resolve_runtime_dll lib_path out_var)
    get_filename_component(_lib_dir "${lib_path}" DIRECTORY)
    get_filename_component(_prefix  "${_lib_dir}" DIRECTORY)
    get_filename_component(_lib_stem "${lib_path}" NAME_WE)
    file(GLOB _candidates
      "${_prefix}/bin/${_lib_stem}.dll"
      "${_prefix}/bin/${_lib_stem}-*.dll"
      "${_prefix}/bin/lib${_lib_stem}.dll"
      "${_prefix}/bin/lib${_lib_stem}-*.dll")
    list(LENGTH _candidates _n)
    if(_n EQUAL 0)
      message(FATAL_ERROR
        "BRAIDLAB_GMP_LINKAGE=bundled on Windows: could not find "
        "runtime DLL for ${lib_path} in ${_prefix}/bin/.  "
        "Check that the vcpkg port installs gmp:x64-windows "
        "(release variant), not just the debug variant.")
    endif()
    list(GET _candidates 0 _dll)
    set(${out_var} "${_dll}" PARENT_SCOPE)
  endfunction()
  _braidlab_resolve_runtime_dll(
    "${BRAIDLAB_GMP_LIBRARY_REAL}"   BRAIDLAB_GMP_LIBRARY_REAL)
  _braidlab_resolve_runtime_dll(
    "${BRAIDLAB_GMPXX_LIBRARY_REAL}" BRAIDLAB_GMPXX_LIBRARY_REAL)
endif()

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

# Bundled-GMP install rules.  Co-locate the resolved GMP runtime
# libraries with the GMP-using MEX files and arrange for the loader
# to find them at MEX load time without any system GMP installed.
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
#
# The MEX records the path Homebrew advertised at link time
# (typically /opt/homebrew/opt/gmp/lib/libgmp.10.dylib, the
# versionless symlink), which differs from the realpath we used
# for install(FILES) (/opt/homebrew/Cellar/gmp/<version>/...).
# `install_name_tool -change` requires an exact match of the OLD
# string, so we discover the actual recorded reference at install
# time with otool and use that.
if(APPLE)
  install(CODE "
    set(_gmp_dir \"\${CMAKE_INSTALL_PREFIX}/${BRAIDLAB_DIR_BRAID_PRIVATE}\")
    set(_gmp_name \"${BRAIDLAB_GMP_LOADER_NAME}\")
    set(_gmpxx_name \"${BRAIDLAB_GMPXX_LOADER_NAME}\")
    foreach(_mex ${BRAIDLAB_GMP_MEX_TARGETS})
      file(GLOB _mex_files \"\${_gmp_dir}/\${_mex}.mex*\")
      foreach(_mex_file \${_mex_files})
        execute_process(COMMAND otool -L \"\${_mex_file}\"
          OUTPUT_VARIABLE _otool_out OUTPUT_STRIP_TRAILING_WHITESPACE)
        string(REGEX MATCHALL \"[^\\n\\t ]*libgmp[^\\n\\t ]*\\\\.dylib\"
          _gmp_refs \"\${_otool_out}\")
        foreach(_gmp_ref \${_gmp_refs})
          if(_gmp_ref MATCHES \"libgmpxx\")
            execute_process(COMMAND install_name_tool
              -change \"\${_gmp_ref}\" \"@loader_path/\${_gmpxx_name}\"
              \"\${_mex_file}\")
          else()
            execute_process(COMMAND install_name_tool
              -change \"\${_gmp_ref}\" \"@loader_path/\${_gmp_name}\"
              \"\${_mex_file}\")
          endif()
        endforeach()
      endforeach()
    endforeach()
    # libgmpxx itself depends on libgmp; rewrite that reference too.
    execute_process(COMMAND otool -L \"\${_gmp_dir}/\${_gmpxx_name}\"
      OUTPUT_VARIABLE _otool_out OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REGEX MATCHALL \"[^\\n\\t ]*libgmp[^\\n\\t ]*\\\\.dylib\"
      _gmp_refs \"\${_otool_out}\")
    foreach(_gmp_ref \${_gmp_refs})
      if(NOT _gmp_ref MATCHES \"libgmpxx\")
        execute_process(COMMAND install_name_tool
          -change \"\${_gmp_ref}\" \"@loader_path/\${_gmp_name}\"
          \"\${_gmp_dir}/\${_gmpxx_name}\")
      endif()
    endforeach()
    execute_process(COMMAND install_name_tool -id \"@loader_path/\${_gmp_name}\"
      \"\${_gmp_dir}/\${_gmp_name}\")
    execute_process(COMMAND install_name_tool -id \"@loader_path/\${_gmpxx_name}\"
      \"\${_gmp_dir}/\${_gmpxx_name}\")
  ")
endif()

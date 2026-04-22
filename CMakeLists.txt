cmake_minimum_required(VERSION 3.20)

project(braidlab LANGUAGES C CXX)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(BRAIDLAB_USE_GMP "Enable GMP-backed code paths when libraries are found" ON)
option(BRAIDLAB_BUILD_DOCS "Enable braidlab-doc target" OFF)

find_package(Matlab REQUIRED COMPONENTS MEX_COMPILER)

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

add_library(cbraid_mex STATIC
  extern/cbraid/lib/cbraid.cpp
  extern/cbraid/lib/braiding.cpp
)
target_include_directories(cbraid_mex PUBLIC "${CMAKE_SOURCE_DIR}/extern/cbraid/include")

add_library(trains STATIC
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
target_include_directories(trains PUBLIC "${CMAKE_SOURCE_DIR}/extern/trains")

set(BRAIDLAB_GMP_LINK_LIBS)
set(BRAIDLAB_GMP_DEFINITIONS)
if(BRAIDLAB_USE_GMP)
  find_library(BRAIDLAB_GMP_LIBRARY NAMES gmp)
  find_library(BRAIDLAB_GMPXX_LIBRARY NAMES gmpxx)
  if(BRAIDLAB_GMP_LIBRARY AND BRAIDLAB_GMPXX_LIBRARY)
    list(APPEND BRAIDLAB_GMP_LINK_LIBS "${BRAIDLAB_GMPXX_LIBRARY}" "${BRAIDLAB_GMP_LIBRARY}")
    list(APPEND BRAIDLAB_GMP_DEFINITIONS BRAIDLAB_USE_GMP)
    message(STATUS "GMP enabled")
  else()
    message(STATUS "GMP not found; building without BRAIDLAB_USE_GMP")
  endif()
endif()

braidlab_add_mex(randomwalk_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/private/randomwalk_helper.cpp"
  "+braidlab/private"
)

braidlab_add_mex(assignmentoptimal
  "${CMAKE_SOURCE_DIR}/extern/assignmentoptimal/assignmentoptimal.c"
  "+braidlab/+util"
)

braidlab_add_mex(looplist_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@loop/private/looplist_helper.c"
  "+braidlab/@loop/private"
)
braidlab_add_mex(intersec_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@loop/private/intersec_helper.cpp"
  "+braidlab/@loop/private"
)
braidlab_add_mex(length_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@loop/private/length_helper.cpp"
  "+braidlab/@loop/private"
)

set(CBRAID_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/extern/cbraid/include")

braidlab_add_mex(cfbraid_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@cfbraid/private/cfbraid_helper.cpp"
  "+braidlab/@cfbraid/private"
  INCLUDE_DIRS "${CBRAID_INCLUDE_DIR}"
  LINK_LIBS cbraid_mex
)
braidlab_add_mex(conjtest_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@cfbraid/private/conjtest_helper.cpp"
  "+braidlab/@cfbraid/private"
  INCLUDE_DIRS "${CBRAID_INCLUDE_DIR}"
  LINK_LIBS cbraid_mex
)

braidlab_add_mex(compact_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@braid/private/compact_helper.cpp"
  "+braidlab/@braid/private"
  INCLUDE_DIRS "${CBRAID_INCLUDE_DIR}"
  LINK_LIBS cbraid_mex
)
braidlab_add_mex(subbraid_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@braid/private/subbraid_helper.cpp"
  "+braidlab/@braid/private"
  INCLUDE_DIRS "${CBRAID_INCLUDE_DIR}"
  LINK_LIBS cbraid_mex
)
braidlab_add_mex(train_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@braid/private/train_helper.cpp"
  "+braidlab/@braid/private"
  INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/extern/trains"
  LINK_LIBS trains
)
braidlab_add_mex(cross2gen_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@braid/private/cross2gen_helper.cpp"
  "+braidlab/@braid/private"
  LINK_LIBS ${BRAIDLAB_GMP_LINK_LIBS}
  COMPILE_DEFINITIONS ${BRAIDLAB_GMP_DEFINITIONS}
)
braidlab_add_mex(loopsigma_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@braid/private/loopsigma_helper.cpp"
  "+braidlab/@braid/private"
  LINK_LIBS ${BRAIDLAB_GMP_LINK_LIBS}
  COMPILE_DEFINITIONS ${BRAIDLAB_GMP_DEFINITIONS}
)
braidlab_add_mex(entropy_helper
  "${CMAKE_SOURCE_DIR}/+braidlab/@braid/private/entropy_helper.cpp"
  "+braidlab/@braid/private"
  INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/+braidlab/@loop/private"
  LINK_LIBS ${BRAIDLAB_GMP_LINK_LIBS}
  COMPILE_DEFINITIONS ${BRAIDLAB_GMP_DEFINITIONS}
)

if(BRAIDLAB_BUILD_DOCS)
  find_program(BRAIDLAB_MAKE_EXECUTABLE NAMES gmake make)
  if(NOT BRAIDLAB_MAKE_EXECUTABLE)
    message(FATAL_ERROR "BRAIDLAB_BUILD_DOCS=ON but make was not found")
  endif()

  add_custom_target(braidlab-doc
    COMMAND "${BRAIDLAB_MAKE_EXECUTABLE}" -C "${CMAKE_SOURCE_DIR}/doc" braidlab_guide.pdf
    COMMENT "Building braidlab_guide.pdf"
    VERBATIM
  )
endif()

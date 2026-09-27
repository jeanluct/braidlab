cmake_minimum_required(VERSION 3.16)

project(trains LANGUAGES CXX)

include(CTest)

option(TRAINS_FAST_MATH "Enable -ffast-math" ON)
option(TRAINS_STRICT_WARNINGS "Enable extra warning checks" OFF)
option(TRAINS_SANITIZE "Build with AddressSanitizer and UBSan" OFF)

# Legacy layout: lib/libtrains.a, src/frontend and src/train, as the old
# Makefiles produced. On by default only for the main build directory
# (build/, which the top-level Makefile uses), so that extra build
# directories such as build-strict or build-asan keep their outputs to
# themselves instead of overwriting the main build's.
if(CMAKE_BINARY_DIR STREQUAL "${CMAKE_SOURCE_DIR}/build")
    set(TRAINS_IN_TREE_DEFAULT ON)
else()
    set(TRAINS_IN_TREE_DEFAULT OFF)
endif()
option(TRAINS_IN_TREE_OUTPUTS
    "Put libtrains.a in lib/ and executables in src/ (legacy layout)"
    ${TRAINS_IN_TREE_DEFAULT})

if(TRAINS_SANITIZE)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        # Directory-wide so that the library, executables and tests all get
        # it; must come before any target is defined.
        add_compile_options(-fsanitize=address,undefined
            -fno-sanitize-recover=undefined -fno-omit-frame-pointer -g)
        add_link_options(-fsanitize=address,undefined)
    else()
        message(WARNING "TRAINS_SANITIZE is only supported with GCC/Clang")
    endif()
endif()

set(TRAINS_LIBRARY_SOURCES
    src/Batch.cpp
    src/braid.cpp
    src/edgevert.cpp
    src/embedding.cpp
    src/General.cpp
    src/Graphalg.cpp
    src/graph.cpp
    src/Graphset.cpp
    src/Graputil.cpp
    src/help.cpp
    src/hshoe.cpp
    src/Matrix.cpp
    src/ttt.cpp
)

add_library(trains STATIC ${TRAINS_LIBRARY_SOURCES})
target_include_directories(trains PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_compile_options(trains PRIVATE
    -Wall
    -O3
    -fPIC
)

if(TRAINS_FAST_MATH)
    target_compile_options(trains PRIVATE -ffast-math)
endif()

add_executable(frontend src/frontend.cpp)
target_link_libraries(frontend PRIVATE trains)

add_executable(train src/train.cpp)
target_link_libraries(train PRIVATE trains)

if(TRAINS_IN_TREE_OUTPUTS)
    set_target_properties(trains PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
    )
    set_target_properties(frontend train PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
    )
endif()

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

if(TRAINS_STRICT_WARNINGS)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        set(TRAINS_STRICT_WARNING_FLAGS
            -Wextra
            -Wpedantic
            -Wconversion
            -Wsign-conversion
            -Wshadow
            -Wformat=2
            -Wnull-dereference
            -Wdouble-promotion
            -Wimplicit-fallthrough
            -Wcast-qual
            -Wcast-align
            -Woverloaded-virtual
            -Wnon-virtual-dtor
            -Wold-style-cast
            -Wmisleading-indentation
            -Wundef
            -Wredundant-decls
            -Wctor-dtor-privacy
            -Wextra-semi
            -Wzero-as-null-pointer-constant
        )
        # GCC-only warnings; Clang rejects them as unknown options.
        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            list(APPEND TRAINS_STRICT_WARNING_FLAGS
                -Wduplicated-cond
                -Wduplicated-branches
                -Wlogical-op
                -Wuseless-cast
            )
        endif()
        target_compile_options(trains PRIVATE ${TRAINS_STRICT_WARNING_FLAGS})
        target_compile_options(frontend PRIVATE ${TRAINS_STRICT_WARNING_FLAGS})
        target_compile_options(train PRIVATE ${TRAINS_STRICT_WARNING_FLAGS})
    elseif(MSVC)
        target_compile_options(trains PRIVATE /W4)
        target_compile_options(frontend PRIVATE /W4)
        target_compile_options(train PRIVATE /W4)
    endif()
endif()

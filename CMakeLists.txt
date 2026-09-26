cmake_minimum_required(VERSION 3.16)

project(trains LANGUAGES CXX)

include(CTest)

option(TRAINS_FAST_MATH "Enable -ffast-math" ON)
option(TRAINS_STRICT_WARNINGS "Enable extra warning checks" OFF)
option(TRAINS_SANITIZE "Build with AddressSanitizer and UBSan" OFF)

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

set_target_properties(trains PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/lib"
)

add_executable(frontend src/frontend.cpp)
target_link_libraries(frontend PRIVATE trains)
set_target_properties(frontend PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

add_executable(train src/train.cpp)
target_link_libraries(train PRIVATE trains)
set_target_properties(train PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

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
            -Wduplicated-cond
            -Wduplicated-branches
            -Wlogical-op
            -Wuseless-cast
            -Wmisleading-indentation
            -Wundef
            -Wredundant-decls
            -Wctor-dtor-privacy
            -Wextra-semi
            -Wzero-as-null-pointer-constant
        )
        target_compile_options(trains PRIVATE ${TRAINS_STRICT_WARNING_FLAGS})
        target_compile_options(frontend PRIVATE ${TRAINS_STRICT_WARNING_FLAGS})
        target_compile_options(train PRIVATE ${TRAINS_STRICT_WARNING_FLAGS})
    elseif(MSVC)
        target_compile_options(trains PRIVATE /W4)
        target_compile_options(frontend PRIVATE /W4)
        target_compile_options(train PRIVATE /W4)
    endif()
endif()

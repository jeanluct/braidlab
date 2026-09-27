set(TRAINS_TEST_COMMON_SOURCES
    test_runtime.cpp
)

set(TRAINS_TEST_COMMON_LIBS
    trains
)

add_executable(test_newarray_embedding
    test_newarray_embedding.cpp
    ${TRAINS_TEST_COMMON_SOURCES}
)
target_include_directories(test_newarray_embedding PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(test_newarray_embedding PRIVATE ${TRAINS_TEST_COMMON_LIBS})
add_test(NAME test_newarray_embedding COMMAND test_newarray_embedding)
set_tests_properties(test_newarray_embedding PROPERTIES LABELS "library;array;embedding")

add_executable(test_myarray
    test_myarray.cpp
    ${TRAINS_TEST_COMMON_SOURCES}
)
target_include_directories(test_myarray PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(test_myarray PRIVATE ${TRAINS_TEST_COMMON_LIBS})
add_test(NAME test_myarray COMMAND test_myarray)
set_tests_properties(test_myarray PROPERTIES LABELS "library;array" TIMEOUT 30)

add_executable(test_braid_horseshoe_batch
    test_braid_horseshoe_batch.cpp
    ${TRAINS_TEST_COMMON_SOURCES}
)
target_include_directories(test_braid_horseshoe_batch PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(test_braid_horseshoe_batch PRIVATE ${TRAINS_TEST_COMMON_LIBS})
add_test(NAME test_braid_horseshoe_batch COMMAND test_braid_horseshoe_batch)
set_tests_properties(test_braid_horseshoe_batch PROPERTIES LABELS "library;braid;horseshoe;batch")

add_executable(test_graph_setup
    test_graph_setup.cpp
    ${TRAINS_TEST_COMMON_SOURCES}
)
target_include_directories(test_graph_setup PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(test_graph_setup PRIVATE ${TRAINS_TEST_COMMON_LIBS})
add_test(NAME test_graph_setup COMMAND test_graph_setup)
set_tests_properties(test_graph_setup PROPERTIES LABELS "library;graph;setup")

add_executable(test_graph_matrix
    test_graph_matrix.cpp
    ${TRAINS_TEST_COMMON_SOURCES}
)
target_include_directories(test_graph_matrix PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(test_graph_matrix PRIVATE ${TRAINS_TEST_COMMON_LIBS})
add_test(NAME test_graph_matrix COMMAND test_graph_matrix)
set_tests_properties(test_graph_matrix PROPERTIES LABELS "library;graph;matrix")

add_executable(test_graph_io
    test_graph_io.cpp
    ${TRAINS_TEST_COMMON_SOURCES}
)
target_include_directories(test_graph_io PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(test_graph_io PRIVATE ${TRAINS_TEST_COMMON_LIBS})
add_test(NAME test_graph_io COMMAND test_graph_io)
set_tests_properties(test_graph_io PROPERTIES LABELS "library;graph;io")

add_executable(test_graph_algorithms
    test_graph_algorithms.cpp
    ${TRAINS_TEST_COMMON_SOURCES}
)
target_include_directories(test_graph_algorithms PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(test_graph_algorithms PRIVATE ${TRAINS_TEST_COMMON_LIBS})
add_test(NAME test_graph_algorithms COMMAND test_graph_algorithms)
set_tests_properties(test_graph_algorithms PROPERTIES LABELS "library;graph;algorithms")

add_executable(test_misc_components
    test_misc_components.cpp
    ${TRAINS_TEST_COMMON_SOURCES}
)
target_include_directories(test_misc_components PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(test_misc_components PRIVATE ${TRAINS_TEST_COMMON_LIBS})
add_test(NAME test_misc_components COMMAND test_misc_components)
set_tests_properties(test_misc_components PROPERTIES LABELS "library;misc")

add_test(
    NAME test_frontend_horseshoe_ttt
    COMMAND /bin/sh -c "printf 'horseshoe\n1\n10010\ntrain\nttt\nquit\n' | $<TARGET_FILE:frontend>"
)
set_tests_properties(test_frontend_horseshoe_ttt PROPERTIES LABELS "integration;frontend;ttt")

add_test(NAME test_train_pseudo_anosov COMMAND train 3 1 -2)
set_tests_properties(test_train_pseudo_anosov PROPERTIES
    LABELS "integration;train"
    PASS_REGULAR_EXPRESSION "Thurston type = Pseudo-Anosov")

add_test(NAME test_train_finite_order COMMAND train 3 1 2)
set_tests_properties(test_train_finite_order PROPERTIES
    LABELS "integration;train"
    PASS_REGULAR_EXPRESSION "Thurston type = Finite Order")

add_test(NAME test_train_reducible COMMAND train 4 1 3)
set_tests_properties(test_train_reducible PROPERTIES
    LABELS "integration;train"
    PASS_REGULAR_EXPRESSION "Thurston type = Reducible")

# Golden regression: exact output of a braid/horseshoe corpus (type, growth,
# singularities, transition matrices, graph dumps). The expected file was
# generated from master before the strict-warning cleanup. Regenerate it
# only for intended behavior changes, and explain the diff in the commit.
add_test(
    NAME test_golden_batch
    COMMAND ${CMAKE_COMMAND}
        -DFRONTEND=$<TARGET_FILE:frontend>
        -DGOLDEN_DIR=${CMAKE_CURRENT_SOURCE_DIR}/golden
        -DACTUAL=${CMAKE_CURRENT_BINARY_DIR}/golden_batch.actual
        -P ${CMAKE_CURRENT_SOURCE_DIR}/golden/run_golden.cmake
)
set_tests_properties(test_golden_batch PROPERTIES
    LABELS "integration;golden;regression")

# Tokens longer than 20 characters used to overflow frontend's parse buffers
# (heap overflow in Parse, then strcpy into Filename[20]). Only a sanitizer
# build reliably detects a regression here.
add_test(
    NAME test_frontend_long_token
    COMMAND /bin/sh -c "printf 'run a_batch_file_name_well_over_twenty_characters.txt\nquit\n' | $<TARGET_FILE:frontend>"
)
set_tests_properties(test_frontend_long_token PROPERTIES
    LABELS "integration;frontend"
    PASS_REGULAR_EXPRESSION "Cannot find batch file")

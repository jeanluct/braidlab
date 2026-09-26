# Run the golden batch file through frontend and compare its output (which
# BatchProcess writes to stderr) against the stored expected output.
#
# Usage: cmake -DFRONTEND=<path> -DGOLDEN_DIR=<dir> -DACTUAL=<file>
#              -P run_golden.cmake

execute_process(
    COMMAND "${FRONTEND}"
    INPUT_FILE "${GOLDEN_DIR}/commands.txt"
    WORKING_DIRECTORY "${GOLDEN_DIR}"
    OUTPUT_VARIABLE frontend_stdout
    ERROR_FILE "${ACTUAL}"
    RESULT_VARIABLE rc
)

if(NOT rc EQUAL 0)
    message(FATAL_ERROR "frontend exited with ${rc}\n${frontend_stdout}")
endif()

if(NOT frontend_stdout MATCHES "Run was successful")
    message(FATAL_ERROR "Batch run did not complete:\n${frontend_stdout}")
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND} -E compare_files
        "${ACTUAL}" "${GOLDEN_DIR}/braids.expected"
    RESULT_VARIABLE differ
)

if(differ)
    message(FATAL_ERROR "Output differs from braids.expected; compare with\n"
        "  diff ${GOLDEN_DIR}/braids.expected ${ACTUAL}")
endif()

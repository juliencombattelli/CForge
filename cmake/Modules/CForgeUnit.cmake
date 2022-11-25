# TEST_SCRIPT: script to run the test (unit test execution and assertions if applicable)
# TEST_COMMAND: command to run the test (unit test execution and assertions if applicable)
# VERIFY_SCRIPT: script to do post test execution processing (like log analysis)
# VERIFY_COMMAND: command to do post test execution processing (like log analysis)
# TEST_SHALL_FAIL: whether the TEST_SCRIPT is expected to fail (useful if fatal error occur in test script)
function(cforge_unit_run_test)
    cmake_parse_arguments("ARG"
        "TEST_SHALL_FAIL"
        "TEST_SUITE;TEST_CASE"
        "TEST_SCRIPT;TEST_COMMAND;VERIFY_SCRIPT;VERIFY_COMMAND"
        ${ARGN}
    )

    if(NOT ARG_TEST_SUITE)
        message(FATAL_ERROR "TEST_SUITE argument is required")
    endif()
    if(NOT ARG_TEST_CASE)
        message(FATAL_ERROR "TEST_CASE argument is required")
    endif()
    if(NOT ARG_TEST_SCRIPT AND NOT ARG_TEST_COMMAND)
        message(FATAL_ERROR "Either TEST_SCRIPT or TEST_COMMAND argument must be specified")
    endif()

    message(CHECK_START "Running test ${ARG_TEST_SUITE}.${ARG_TEST_CASE}")

    # TODO Use JSON for tests registration and execution stats
    # TODO Use TEST_SUITE and TEST_CASE to automatically search for the scripts

    # Run test phase

    if(ARG_TEST_SCRIPT)
        # TODO check availability of script
        string(MAKE_C_IDENTIFIER "${ARG_TEST_SCRIPT}" SCRIPT_ID)
        get_filename_component(SCRIPT_PATH "${ARG_TEST_SCRIPT}" ABSOLUTE)
        get_filename_component(SCRIPT_DIRECTORY "${SCRIPT_PATH}" DIRECTORY)
        set(CFORGE_UNIT_CURRENT_TEST_OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/${SCRIPT_ID}.output.txt)
        set(CFORGE_UNIT_CURRENT_TEST_ERROR_FILE ${CMAKE_CURRENT_BINARY_DIR}/${SCRIPT_ID}.error.txt)
        execute_process(
            COMMAND ${CMAKE_COMMAND} -P ${ARG_TEST_SCRIPT}
            WORKING_DIRECTORY "${SCRIPT_DIRECTORY}"
            OUTPUT_FILE ${CFORGE_UNIT_CURRENT_TEST_OUTPUT_FILE}
            ERROR_FILE ${CFORGE_UNIT_CURRENT_TEST_ERROR_FILE}
            RESULT_VARIABLE TEST_RESULT
        )
        if(NOT ARG_TEST_SHALL_FAIL AND NOT TEST_RESULT EQUAL 0)
            # Script/command failed but was expected to pass
            message(SEND_ERROR "Test failed with code ${TEST_RESULT} (expected: code == 0)")
            set(TEST_FAILED YES)
        elseif(ARG_TEST_SHALL_FAIL AND TEST_RESULT EQUAL 0)
            # Script/command passed but was expected to fail
            message(SEND_ERROR "Test failed with code ${TEST_RESULT} (expected: code != 0)")
            set(TEST_FAILED YES)
        endif()
    endif()

    if(ARG_TEST_COMMAND)
        if(COMMAND ${ARG_TEST_COMMAND})
            cmake_language(CALL ${ARG_TEST_COMMAND} TEST_RESULT)
            if(TEST_RESULT AND NOT TEST_RESULT EQUAL 0)
                set(TEST_FAILED YES)
            endif()
        else()
            message(FATAL_ERROR "Argument TEST_COMMAND is not a known CMake command (${ARG_TEST_COMMAND}).")
        endif()
    endif()

    # Run verification phase

    if(ARG_VERIFY_SCRIPT)
        # TODO check availability of script
        string(MAKE_C_IDENTIFIER "${ARG_VERIFY_SCRIPT}" SCRIPT_ID)
        get_filename_component(SCRIPT_PATH "${ARG_VERIFY_SCRIPT}" ABSOLUTE)
        get_filename_component(SCRIPT_DIRECTORY "${SCRIPT_PATH}" DIRECTORY)
        set(CFORGE_UNIT_CURRENT_VERIFY_OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/${SCRIPT_ID}.output.txt)
        set(CFORGE_UNIT_CURRENT_VERIFY_ERROR_FILE ${CMAKE_CURRENT_BINARY_DIR}/${SCRIPT_ID}.error.txt)
        execute_process(
            COMMAND ${CMAKE_COMMAND}
                -D CFORGE_UNIT_CURRENT_TEST_OUTPUT_FILE=${CFORGE_UNIT_CURRENT_TEST_OUTPUT_FILE}
                -D CFORGE_UNIT_CURRENT_TEST_ERROR_FILE=${CFORGE_UNIT_CURRENT_TEST_ERROR_FILE}
                -P ${ARG_VERIFY_SCRIPT}
            WORKING_DIRECTORY "${SCRIPT_DIRECTORY}"
            OUTPUT_FILE ${CFORGE_UNIT_CURRENT_VERIFY_OUTPUT_FILE}
            ERROR_FILE ${CFORGE_UNIT_CURRENT_VERIFY_ERROR_FILE}
            RESULT_VARIABLE VERIFY_RESULT
        )
        if(VERIFY_RESULT AND NOT VERIFY_RESULT EQUAL 0)
            set(VERIFY_FAILED YES)
        endif()
    endif()

    if(ARG_VERIFY_COMMAND)
        if(COMMAND ${ARG_VERIFY_COMMAND})
            cmake_language(CALL ${ARG_VERIFY_COMMAND} VERIFY_RESULT)
            if(VERIFY_RESULT AND NOT VERIFY_RESULT EQUAL 0)
                set(VERIFY_FAILED YES)
            endif()
        else()
            message(FATAL_ERROR "Argument VERIFY_COMMAND is not a known CMake command (${ARG_VERIFY_COMMAND}).")
        endif()
    endif()

    # Print test verdict

    if(TEST_FAILED OR VERIFY_FAILED)
        message(CHECK_FAIL "failed")
    else()
        message(CHECK_PASS "passed")
    endif()
endfunction()

function(cforge_unit_add_test_subdirectory DIRECTORY)
    cmake_parse_arguments("ARG" "USE_CTEST" "" "" ${ARGN})

    if(DEFINED CFORGE_UNIT_USE_CTEST)
        set(ARG_USE_CTEST ${CFORGE_UNIT_USE_CTEST})
    endif()

    file(REAL_PATH "${DIRECTORY}" DIRECTORY_REAL_PATH)
    if(NOT IS_DIRECTORY "${DIRECTORY_REAL_PATH}")
        message(FATAL_ERROR "Not a directory")
    endif()

    if(ARG_USE_CTEST)
        get_filename_component(FOLDER_NAME "${DIRECTORY_REAL_PATH}" NAME)
        add_test(
            NAME "${FOLDER_NAME}"
            COMMAND ${CMAKE_COMMAND} -S "${DIRECTORY_REAL_PATH}" -B "${CMAKE_CURRENT_BINARY_DIR}/${DIRECTORY}"
        )
    else()
        add_subdirectory(${DIRECTORY})
    endif()
endfunction()

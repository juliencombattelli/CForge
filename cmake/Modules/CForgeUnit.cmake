cmake_minimum_required(VERSION 3.19) # For string(JSON)

# CFORGE_UNIT_PROJECT: Top-level project that included CForgeUnit (analog to CMAKE_PROJECT_NAME)
if(NOT CFORGE_UNIT_PROJECT)
    set(CFORGE_UNIT_PROJECT ${PROJECT_NAME})
endif()

include_guard()

function(_cforge_unit_report_verdict TEST_SUITE TEST_CASE VERDICT)
    set(VALID_VERDICTS "unknown;passed;failed")
    if(NOT VERDICT IN_LIST VALID_VERDICTS)
        message(FATAL_ERROR "Invalid verdict")
    endif()
    set(CFORGE_UNIT_VERDICT_${CFORGE_UNIT_PROJECT}__${TEST_SUITE}__${TEST_CASE} ${VERDICT} CACHE INTERNAL "")
endfunction()

function(_cforge_unit_report_verdict_passed TEST_SUITE TEST_CASE)
    _cforge_unit_report_verdict(${TEST_SUITE} ${TEST_CASE} passed)
endfunction()

function(_cforge_unit_report_verdict_failed TEST_SUITE TEST_CASE)
    _cforge_unit_report_verdict(${TEST_SUITE} ${TEST_CASE} failed)
endfunction()

function(_cforge_unit_register_test TEST_SUITE TEST_CASE)
    message(DEBUG "Registering test case ${TEST_SUITE}.${TEST_CASE}")

    list(FIND CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT} "${TEST_SUITE}" SUITE_INDEX)
    if(SUITE_INDEX EQUAL -1)
        list(APPEND CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT} "${TEST_SUITE}")
        set(CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT} ${CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT}} CACHE INTERNAL "")
    endif()

    list(FIND CFORGE_UNIT_${CFORGE_UNIT_PROJECT}__${TEST_SUITE} "${TEST_CASE}" CASE_INDEX)
    if(CASE_INDEX EQUAL -1)
        list(APPEND CFORGE_UNIT_${CFORGE_UNIT_PROJECT}__${TEST_SUITE} "${TEST_CASE}")
        set(CFORGE_UNIT_${CFORGE_UNIT_PROJECT}__${TEST_SUITE} ${CFORGE_UNIT_${CFORGE_UNIT_PROJECT}__${TEST_SUITE}} CACHE INTERNAL "")
    endif()

    _cforge_unit_report_verdict(${TEST_SUITE} ${TEST_CASE} unknown)
endfunction()

# TEST_SCRIPT: script to run the test (unit test execution and assertions if applicable)
# TEST_COMMAND: command to run the test (unit test execution and assertions if applicable)
# VERIFY_SCRIPT: script to do post test execution processing (like log analysis)
# VERIFY_COMMAND: command to do post test execution processing (like log analysis)
# TEST_SHALL_FAIL: whether the TEST_SCRIPT is expected to fail (useful if fatal error occur in test script)
function(cforge_unit_add_test)
    cmake_parse_arguments("ARG"
        "USE_CTEST;TEST_SHALL_FAIL"
        "TEST_SUITE;TEST_CASE"
        "TEST_SCRIPT;VERIFY_SCRIPT"
        ${ARGN}
    )

    if(NOT ARG_TEST_SUITE)
        message(FATAL_ERROR "TEST_SUITE argument is required")
    endif()
    if(NOT ARG_TEST_CASE)
        message(FATAL_ERROR "TEST_CASE argument is required")
    endif()
    if(NOT ARG_TEST_SCRIPT)
        message(FATAL_ERROR "TEST_SCRIPT argument is required")
    endif()

    if(DEFINED CFORGE_UNIT_USE_CTEST)
        set(ARG_USE_CTEST ${CFORGE_UNIT_USE_CTEST})
    endif()

    # TODO check availability of scripts

    if(ARG_TEST_SCRIPT)
        get_filename_component(ARG_TEST_SCRIPT "${ARG_TEST_SCRIPT}" ABSOLUTE)
    endif()

    if(ARG_VERIFY_SCRIPT)
        get_filename_component(ARG_VERIFY_SCRIPT "${ARG_VERIFY_SCRIPT}" ABSOLUTE)
    endif()

    set(TEST_ID "${CFORGE_UNIT_PROJECT}__${ARG_TEST_SUITE}__${ARG_TEST_CASE}")

    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeUnit/RunTest.cmake.in
        ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/${TEST_ID}.cmake
        @ONLY
    )

    if(ARG_USE_CTEST)
        # Register test for deferred invokation using CTest
        unset(CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT} CACHE)
        configure_file(
            ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeUnit/CTestRunner.CMakeLists.txt.in
            ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/${TEST_ID}/CMakeLists.txt
            @ONLY
        )
        add_test(
            NAME "${TEST_ID}"
            COMMAND ${CMAKE_COMMAND}
                -S "${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/${TEST_ID}"
                -B "${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/${TEST_ID}/build"
        )
    else()
        # Register test for immediate invokation
        _cforge_unit_register_test(${ARG_TEST_SUITE} ${ARG_TEST_CASE})
    endif()
endfunction()

function(cforge_unit_run_tests)
    message(CHECK_START "Running all tests")
    foreach(SUITE IN LISTS CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT})
        list(APPEND CMAKE_MESSAGE_INDENT "  ")
        message(CHECK_START "Running test cases from suite ${SUITE}")
        foreach(CASE IN LISTS CFORGE_UNIT_${CFORGE_UNIT_PROJECT}__${SUITE})
            list(APPEND CMAKE_MESSAGE_INDENT "  ")
            message(CHECK_START "Running test ${SUITE}.${CASE}")
            include(${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/${CFORGE_UNIT_PROJECT}__${SUITE}__${CASE}.cmake)
            _cforge_unit_run_test()
            if(CFORGE_UNIT_VERDICT_${CFORGE_UNIT_PROJECT}__${SUITE}__${CASE} STREQUAL failed)
                message(CHECK_FAIL "failed")
            else()
                message(CHECK_PASS "passed")
            endif()
            list(POP_BACK CMAKE_MESSAGE_INDENT)
        endforeach()
        message(CHECK_PASS "passed (verdict stubbed)")
        list(POP_BACK CMAKE_MESSAGE_INDENT)
    endforeach()
    message(CHECK_PASS "passed (verdict stubbed)")
endfunction()

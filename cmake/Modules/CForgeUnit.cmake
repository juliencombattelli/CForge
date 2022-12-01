cmake_minimum_required(VERSION 3.19)

# CFORGE_UNIT_PROJECT: Top-level project that included CForgeUnit (analog to CMAKE_PROJECT_NAME)
if(NOT CFORGE_UNIT_PROJECT)
    set(CFORGE_UNIT_PROJECT ${PROJECT_NAME})
endif()

include_guard()

include(${CMAKE_CURRENT_LIST_DIR}/CForgeUnit/CForgeUnitDetails.cmake)

# TEST_SCRIPT: script to run the test (unit test execution and assertions if applicable)
# VERIFY_SCRIPT: script to do post test execution processing (like log analysis)
# TEST_SHALL_FAIL: whether the TEST_SCRIPT is expected to fail (useful if fatal error occur in test script)
# USE_CTEST: execute the test during ctest instead of configuration
# LANGUAGES: Languages enabled during the test phase (default NONE)
function(cforge_unit_add_test)
    cmake_parse_arguments("ARG"
        "USE_CTEST;TEST_SHALL_FAIL"
        "TEST_SUITE;TEST_CASE;TEST_SCRIPT;VERIFY_SCRIPT"
        "LANGUAGES"
        ${ARGN}
    )

    if(NOT ARG_TEST_SUITE)
        message(FATAL_ERROR "TEST_SUITE argument is required")
    endif()
    if(NOT ARG_TEST_CASE)
        message(FATAL_ERROR "TEST_CASE argument is required")
    endif()

    if(NOT ARG_LANGUAGES)
        set(ARG_LANGUAGES NONE)
    endif()

    if(DEFINED CFORGE_UNIT_USE_CTEST)
        set(ARG_USE_CTEST ${CFORGE_UNIT_USE_CTEST})
    endif()

    if(NOT ARG_TEST_SCRIPT)
        set(ARG_TEST_SCRIPT "${ARG_TEST_CASE}.test.cmake")
    endif()
    get_filename_component(ARG_TEST_SCRIPT "${ARG_TEST_SCRIPT}" ABSOLUTE)
    if(NOT EXISTS "${ARG_TEST_SCRIPT}")
        message(FATAL_ERROR "Test script file not found: ${ARG_TEST_SCRIPT}")
    endif()

    if(ARG_VERIFY_SCRIPT)
        set(VERIFY_SCRIPT_SPECIFIED TRUE)
    else()
        set(VERIFY_SCRIPT_SPECIFIED FALSE)
        set(ARG_VERIFY_SCRIPT "${ARG_TEST_CASE}.verify.cmake")
    endif()
    get_filename_component(ARG_VERIFY_SCRIPT "${ARG_VERIFY_SCRIPT}" ABSOLUTE)
    # VERIFY_SCRIPT is optional, so if it is not found:
    #   - a fatal error is shown if it is explicitly specified
    #   - otherwise the variable is just unset
    if(NOT EXISTS "${ARG_VERIFY_SCRIPT}")
        if(VERIFY_SCRIPT_SPECIFIED)
            message(FATAL_ERROR "Verify script file not found: ${ARG_VERIFY_SCRIPT}")
        endif()
        unset(ARG_VERIFY_SCRIPT)
    endif()

    _cforge_unit_set_context("${ARG_TEST_SUITE}" "${ARG_TEST_CASE}")

    configure_file(
        "${_CFORGE_UNIT_TEMPLATE_DIR}/ContextCache.cmake.in"
        "${_CFORGE_UNIT_CURRENT_TEST_SCRIPT_DIR}/ContextCache.cmake"
        @ONLY
    )

    configure_file(
        "${_CFORGE_UNIT_TEMPLATE_DIR}/RunTest.CMakeLists.txt.in"
        "${_CFORGE_UNIT_CURRENT_TEST_SCRIPT_DIR}/CMakeLists.txt"
        @ONLY
    )

    configure_file(
        "${_CFORGE_UNIT_TEMPLATE_DIR}/RunTest.cmake.in"
        "${_CFORGE_UNIT_CURRENT_TEST_SCRIPT_DIR}/RunTest.cmake"
        @ONLY
    )

    if(ARG_USE_CTEST)
        # Register test for deferred invokation using CTest
        unset(CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT} CACHE)
        add_test(
            NAME "${CFORGE_UNIT_CURRENT_TEST_ID}"
            COMMAND ${CMAKE_COMMAND}
                -C "${_CFORGE_UNIT_CURRENT_TEST_SCRIPT_DIR}/ContextCache.cmake"
                -S "${_CFORGE_UNIT_TEMPLATE_DIR}/CTestRunner"
                -B "${_CFORGE_UNIT_CURRENT_TEST_CTEST_BINARY_DIR}"
        )
    else()
        # Register test for immediate invokation
        _cforge_unit_register_test(${ARG_TEST_SUITE} ${ARG_TEST_CASE})
    endif()
endfunction()

function(cforge_unit_run_tests)
    if(NOT CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT})
        return()
    endif()
    message(CHECK_START "Running all tests")
    list(LENGTH CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT} SUITE_COUNT)
    set(SUITE_IDX 0)
    set(SUITE_FAILED_COUNT 0)
    foreach(SUITE IN LISTS CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT})
        list(APPEND CMAKE_MESSAGE_INDENT "  ")
        math(EXPR SUITE_IDX "${SUITE_IDX}+1")
        message(CHECK_START "Running test cases from suite ${SUITE_IDX}/${SUITE_COUNT}: ${SUITE}")
        list(LENGTH CFORGE_UNIT_${CFORGE_UNIT_PROJECT}__${SUITE} CASE_COUNT)
        set(CASE_IDX 0)
        set(CASE_FAILED_COUNT 0)
        foreach(CASE IN LISTS CFORGE_UNIT_${CFORGE_UNIT_PROJECT}__${SUITE})
            list(APPEND CMAKE_MESSAGE_INDENT "  ")
            math(EXPR CASE_IDX "${CASE_IDX}+1")
            message(CHECK_START "Running test case ${CASE_IDX}/${CASE_COUNT}: ${SUITE}.${CASE}")

            _cforge_unit_set_context("${SUITE}" "${CASE}")

            include(${_CFORGE_UNIT_CURRENT_TEST_SCRIPT_DIR}/RunTest.cmake)
            _cforge_unit_run_test()

            if(CFORGE_UNIT_VERDICT_${CFORGE_UNIT_CURRENT_TEST_ID} STREQUAL failed)
                message(CHECK_FAIL "failed")
                math(EXPR CASE_FAILED_COUNT "${CASE_FAILED_COUNT}+1")
            else()
                message(CHECK_PASS "passed")
            endif()

            list(POP_BACK CMAKE_MESSAGE_INDENT)
        endforeach()
        if(CASE_FAILED_COUNT EQUAL 0)
            message(CHECK_PASS "all test cases passed")
        else()
            message(CHECK_FAIL "${CASE_FAILED_COUNT} test cases failed out of ${CASE_COUNT}")
            math(EXPR SUITE_FAILED_COUNT "${SUITE_FAILED_COUNT}+1")
        endif()
        list(POP_BACK CMAKE_MESSAGE_INDENT)
    endforeach()
    if(SUITE_FAILED_COUNT EQUAL 0)
        message(CHECK_PASS "all test suites passed")
    else()
        message(CHECK_FAIL "${SUITE_FAILED_COUNT} test suites failed out of ${SUITE_COUNT}")
    endif()
endfunction()

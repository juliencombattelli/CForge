cmake_minimum_required(VERSION 3.19)

# CFORGE_UNIT_PROJECT: Top-level project that included CForgeUnit (analog to CMAKE_PROJECT_NAME)
if(NOT CFORGE_UNIT_PROJECT)
    set(CFORGE_UNIT_PROJECT ${PROJECT_NAME})
endif()

include_guard()

include(${CMAKE_CURRENT_LIST_DIR}/CForgeUnit/CForgeUnitDetails.cmake)

# TEST_SCRIPT: script to run the test (unit test execution and assertions if applicable)
# TEST_COMMAND: command to run the test (unit test execution and assertions if applicable)
# VERIFY_SCRIPT: script to do post test execution processing (like log analysis)
# VERIFY_COMMAND: command to do post test execution processing (like log analysis)
# TEST_SHALL_FAIL: whether the TEST_SCRIPT is expected to fail (useful if fatal error occur in test script)
# USE_CTEST: execute the test during ctest instead of configuration
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
    message(CHECK_START "Running all tests")
    foreach(SUITE IN LISTS CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT})
        list(APPEND CMAKE_MESSAGE_INDENT "  ")
        message(CHECK_START "Running test cases from suite ${SUITE}")
        foreach(CASE IN LISTS CFORGE_UNIT_${CFORGE_UNIT_PROJECT}__${SUITE})
            list(APPEND CMAKE_MESSAGE_INDENT "  ")
            message(CHECK_START "Running test ${SUITE}.${CASE}")

            _cforge_unit_set_context("${SUITE}" "${CASE}")

            include(${_CFORGE_UNIT_CURRENT_TEST_SCRIPT_DIR}/RunTest.cmake)
            _cforge_unit_run_test()

            if(CFORGE_UNIT_VERDICT_${CFORGE_UNIT_CURRENT_TEST_ID} STREQUAL failed)
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

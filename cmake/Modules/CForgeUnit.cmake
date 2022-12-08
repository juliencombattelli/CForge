cmake_minimum_required(VERSION 3.19)

# CFORGE_UNIT_PROJECT: Top-level project that included CForgeUnit (analog to CMAKE_PROJECT_NAME)
if(NOT CFORGE_UNIT_PROJECT)
    set(CFORGE_UNIT_PROJECT ${PROJECT_NAME})
endif()

include_guard()

# Global variables:
# CFORGE_UNIT_RUN_TESTS_AT_CONFIGURATION: run all tests at configuration
# CFORGE_UNIT_VERBOSE: make test executed at configuration verbose

# SCRIPT: script to run the test (unit test execution and assertions if applicable)
# RUN_AT_CONFIGURATION: execute the test at configuration instead of during ctest execution
# LANGUAGES: languages enabled for the test script execution (default NONE)
# SHALL_FAIL: whether the SCRIPT is expected to fail (useful if fatal error occur in test script)
# PASS_REGEX:
# FAIL_REGEX:
function(cforge_unit_add_test)
    cmake_parse_arguments("ARG"
        "RUN_AT_CONFIGURATION;SHALL_FAIL"
        "TEST_SUITE;TEST_CASE;SCRIPT"
        "LANGUAGES;PASS_REGEX;FAIL_REGEX"
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

    if(DEFINED CFORGE_UNIT_RUN_TESTS_AT_CONFIGURATION)
        set(ARG_RUN_AT_CONFIGURATION ${CFORGE_UNIT_RUN_TESTS_AT_CONFIGURATION})
    endif()

    if(NOT ARG_SCRIPT)
        set(ARG_SCRIPT "${ARG_TEST_CASE}.test.cmake")
    endif()
    get_filename_component(CFORGE_UNIT_CURRENT_TEST_SCRIPT_FILE "${ARG_SCRIPT}" ABSOLUTE)
    if(NOT EXISTS "${CFORGE_UNIT_CURRENT_TEST_SCRIPT_FILE}")
        message(FATAL_ERROR "Test script file not found: ${CFORGE_UNIT_CURRENT_TEST_SCRIPT_FILE}")
    endif()

    # Path to the CForgeUnit CMake module sources
    set(CFORGE_UNIT_SOURCE_DIR "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeUnit")
    # Path to the top level of the CForge build tree for the current project
    set(CFORGE_UNIT_PROJECT_BINARY_DIR "${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit")
    # Test ID for the current CForge test being processed
    set(CFORGE_UNIT_CURRENT_TEST_ID "${CFORGE_UNIT_PROJECT}__${ARG_TEST_SUITE}__${ARG_TEST_CASE}")
    # Path to the build tree of the test being processed
    set(CFORGE_UNIT_CURRENT_TEST_BINARY_DIR
        "${CFORGE_UNIT_PROJECT_BINARY_DIR}/Runner/${CFORGE_UNIT_CURRENT_TEST_ID}"
    )

    configure_file(
        ${CFORGE_UNIT_SOURCE_DIR}/Registrar/CForgeUnitRegisterTest.cmake.in
        ${CFORGE_UNIT_PROJECT_BINARY_DIR}/Registrar/CForgeUnitRegisterTest.${CFORGE_UNIT_CURRENT_TEST_ID}.cmake
        @ONLY
    )

    configure_file(
        ${CFORGE_UNIT_SOURCE_DIR}/Runner/ContextCache.cmake.in
        ${CFORGE_UNIT_CURRENT_TEST_BINARY_DIR}/ContextCache.cmake
        @ONLY
    )

    configure_file(
        ${CFORGE_UNIT_SOURCE_DIR}/Runner/CMakeLists.txt.in
        ${CFORGE_UNIT_CURRENT_TEST_BINARY_DIR}/CMakeLists.txt
        @ONLY
    )

    if(ARG_RUN_AT_CONFIGURATION)
        # Register the test for immediate invokation during configuration phase
        list(APPEND CFORGE_UNIT_REGISTERED_TESTS ${CFORGE_UNIT_CURRENT_TEST_ID})
        set(CFORGE_UNIT_REGISTERED_TESTS ${CFORGE_UNIT_REGISTERED_TESTS} CACHE INTERNAL "")
        configure_file(
            ${CFORGE_UNIT_SOURCE_DIR}/Registrar/ContextCache.cmake.in
            ${CFORGE_UNIT_PROJECT_BINARY_DIR}/Registrar/ContextCache.cmake
            @ONLY
        )
    else()
        # Register the test for invokation during post-build CTest execution
        include(${CFORGE_UNIT_PROJECT_BINARY_DIR}/Registrar/CForgeUnitRegisterTest.${CFORGE_UNIT_CURRENT_TEST_ID}.cmake)
    endif()
endfunction()

function(cforge_unit_run_tests)
    if(NOT CFORGE_UNIT_REGISTERED_TESTS)
        return()
    endif()
    # Add all registered tests to CTest
    execute_process(
        COMMAND ${CMAKE_COMMAND}
            -C ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/Registrar/ContextCache.cmake
            -S ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeUnit/Registrar
            -B ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/Registrar/build
        OUTPUT_FILE ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/configure.out.txt
        ERROR_FILE ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/configure.err.txt
    )
    # Run CTest
    set(ENV{CLICOLOR_FORCE} 1)
    if(CFORGE_UNIT_VERBOSE)
        set(ENV{ARGS} "--output-on-failure --verbose")
    else()
        set(ENV{ARGS} "--output-on-failure")
    endif()
    execute_process(
        COMMAND ${CMAKE_COMMAND}
            --build ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/Registrar/build
            --target test
        RESULT_VARIABLE RESULT
    )
    unset(CFORGE_UNIT_REGISTERED_TESTS CACHE)
    if(NOT RESULT EQUAL 0)
        message(FATAL_ERROR "CForgeUnit test failure")
    endif()
endfunction()

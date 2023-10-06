cmake_minimum_required(VERSION 3.19)

# CFORGE_UNIT_PROJECT: Project that included CForgeUnit
if(NOT CFORGE_UNIT_PROJECT)
    set(CFORGE_UNIT_PROJECT ${PROJECT_NAME})
endif()

include_guard(GLOBAL)

include(CForgeProjectInfo)

include(CForgeAssert)

option(${CFORGE_PROJECT_PREFIX}_UNIT_RUN_TESTS_AT_CONFIGURATION "Run CForgeUnit test suite at configuration instead of during CTest phase" OFF)
option(${CFORGE_PROJECT_PREFIX}_UNIT_VERBOSE "Run CForgeUnit test suites using CTest verbose mode" OFF)

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

    cforge_assert(CONDITION ARG_TEST_SUITE MESSAGE "TEST_SUITE argument is required")
    cforge_assert(CONDITION ARG_TEST_CASE MESSAGE "TEST_CASE argument is required")

    if(NOT ARG_LANGUAGES)
        set(ARG_LANGUAGES NONE)
    endif()

    if(DEFINED ${CFORGE_PROJECT_PREFIX}_UNIT_RUN_TESTS_AT_CONFIGURATION)
        set(ARG_RUN_AT_CONFIGURATION ${${CFORGE_PROJECT_PREFIX}_UNIT_RUN_TESTS_AT_CONFIGURATION})
    endif()

    if(NOT ARG_SCRIPT)
        set(ARG_SCRIPT "${ARG_TEST_CASE}.test.cmake")
    endif()
    get_filename_component(CFORGE_UNIT_CURRENT_TEST_SCRIPT_FILE "${ARG_SCRIPT}" ABSOLUTE)
    cforge_assert(CONDITION EXISTS "${CFORGE_UNIT_CURRENT_TEST_SCRIPT_FILE}"
        MESSAGE "Test script file not found: ${CFORGE_UNIT_CURRENT_TEST_SCRIPT_FILE}"
    )

    # Path to the CForgeUnit CMake module sources
    set(CFORGE_UNIT_SOURCE_DIR "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeUnit")
    # Path to the top level of the source tree for the current project
    set(CFORGE_UNIT_PROJECT_SOURCE_DIR "${${CFORGE_UNIT_PROJECT}_SOURCE_DIR}")
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

function(cforge_unit_add_coverage)
    # TODO Must test hybrid configuration with tests at both configuration-time and CTest execution-time
    set(TEST_IS_COVERAGE ON)
    cforge_unit_add_test(TEST_SUITE coverage TEST_CASE analysis
        SCRIPT ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeUnit/Coverage/RunCoverage.cmake
    )
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
        OUTPUT_FILE ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/Registrar/configure.out.txt
        ERROR_FILE ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/Registrar/configure.err.txt
    )
    # Run CTest
    set(ENV{CLICOLOR_FORCE} 1)
    if(${CFORGE_PROJECT_PREFIX}_UNIT_VERBOSE)
        set(CTEST_ARGS --output-on-failure --verbose)
    else()
        set(CTEST_ARGS --output-on-failure)
    endif()
    get_property(IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(IS_MULTI_CONFIG)
        # Multi-config generators need a configuration to run CTest, so take the first one in the list
        # Which one does not really matter since it is mainly to test CMake code, not to compile things
        list(GET CMAKE_CONFIGURATION_TYPES 0 CURRENT_CONFIG)
        set(CTEST_ARGS ${CTEST_ARGS} -C ${CURRENT_CONFIG})
    endif()
    execute_process(
        COMMAND ${CMAKE_CTEST_COMMAND} ${CTEST_ARGS}
        RESULT_VARIABLE RESULT
        WORKING_DIRECTORY ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit/Registrar/build
    )
    unset(CFORGE_UNIT_REGISTERED_TESTS CACHE)
    cforge_assert(CONDITION RESULT EQUAL 0 MESSAGE "CForgeUnit test failure")
endfunction()

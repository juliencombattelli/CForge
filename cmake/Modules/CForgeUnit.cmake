cmake_minimum_required(VERSION 3.19) # For string(JSON)

# CFORGE_UNIT_PROJECT: Top-level project that included CForgeUnit (analog to CMAKE_PROJECT_NAME)
# CFORGE_UNIT_CURRENT_PROJECT: Project that most recently included CForgeUnit (analog to PROJECT_NAME)

if(NOT CFORGE_UNIT_PROJECT)
    set(CFORGE_UNIT_PROJECT ${PROJECT_NAME})
endif()
set(CFORGE_UNIT_CURRENT_PROJECT ${PROJECT_NAME})

include_guard()

# TODO might be needed later on
# function(cforge_unit_init)
#     cmake_parse_arguments("ARG" "" "PROJECT" "" ${ARGN})
#     if(ARG_PROJECT)
#         if(NOT ${ARG_PROJECT}_SOURCE_DIR OR NOT ${ARG_PROJECT}_BINARY_DIR)
#             message(FATAL_ERROR "Project ${ARG_PROJECT} is not a known project.")
#         endif()
#         set(CFORGE_UNIT_PROJECT ${ARG_PROJECT})
#     endif()
# endfunction()





# JSON report generation
# Too complexe to write using string(JSON) APIs
# CACHE variable are used as a replacement for now

# macro(_cforge_unit_report_read_file CONTENT)
#     file(READ
#         "${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/${CFORGE_UNIT_PROJECT}_cforge-unit-report.json"
#         ${CONTENT}
#     )
# endmacro()

# macro(_cforge_unit_report_write_file CONTENT)
#     file(WRITE
#         "${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/${CFORGE_UNIT_PROJECT}_cforge-unit-report.json"
#         "${CONTENT}"
#     )
# endmacro()

# function(_cforge_unit_report_create_file)
#     if(NOT EXISTS ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/${CFORGE_UNIT_PROJECT}_cforge-unit-report.json)
#         message(DEBUG "CForgeUnit report file for project ${CFORGE_UNIT_PROJECT} does not exist, creating it")
#         _cforge_unit_report_write_file("[]")
#     else()
#         message(DEBUG "CForgeUnit report file for project ${CFORGE_UNIT_PROJECT} already exists")
#     endif()
# endfunction()

# macro(_cforge_unit_report_get_count CONTENT COUNT)
#     string(JSON ${COUNT} LENGTH "${CONTENT}")
# endmacro()

# function(_cforge_unit_report_get_test_suite REPORT_FILE TEST_SUITE INDEX OBJECT)
#     _cforge_unit_report_get_count("${REPORT_FILE}" COUNT)
#     message(DEBUG "${COUNT} suites registered in report")
#     if(COUNT GREATER 0)
#         math(EXPR LAST "${COUNT} - 1")
#         foreach(SUITE_IDX RANGE ${LAST})
#             string(JSON SUITE_NAME GET "${REPORT_FILE}" ${SUITE_IDX} test_suite)
#             message(DEBUG "Found suite ${SUITE_NAME} in report")
#             if(TEST_SUITE STREQUAL SUITE_NAME)
#                 message(DEBUG "Suite ${TEST_SUITE} found in report")
#                 string(JSON SUITE_OBJECT GET "${REPORT_FILE}" ${SUITE_IDX})
#                 set(${INDEX} "${SUITE_IDX}" PARENT_SCOPE)
#                 set(${OBJECT} "${SUITE_OBJECT}" PARENT_SCOPE)
#                 return()
#             endif()
#         endforeach()
#     endif()
# endfunction()

# function(_cforge_unit_report_get_test_case TEST_SUITE_CONTENT TEST_CASE CONTENT)
#     string(JSON COUNT LENGTH "${TEST_SUITE_CONTENT}" test_cases)
#     message(DEBUG "${COUNT} cases registered")
#     if(COUNT GREATER 0)
#         math(EXPR LAST "${COUNT} - 1")
#         foreach(CASE_IDX RANGE ${LAST})
#             string(JSON CASE_NAME GET "${TEST_SUITE_CONTENT}" test_cases ${CASE_IDX} test_case)
#             message(DEBUG "Found case ${CASE_NAME}")
#             if(TEST_CASE STREQUAL CASE_NAME)
#                 message(DEBUG "Case ${TEST_CASE} found")
#                 string(JSON CASE_CONTENT GET "${TEST_SUITE_CONTENT}" ${CASE_IDX})
#                 set(${CONTENT} "${CASE_CONTENT}" PARENT_SCOPE)
#                 return()
#             endif()
#         endforeach()
#     endif()
# endfunction()

# function(_cforge_unit_report_register_test TEST_SUITE TEST_CASE)
#     _cforge_unit_report_read_file(REPORT_FILE)

#     message(DEBUG "Registering suite ${TEST_SUITE}")

#     _cforge_unit_report_get_test_suite("${REPORT_FILE}" "${TEST_SUITE}" SUITE_INDEX SUITE_OBJECT)
#     if(NOT SUITE_OBJECT)
#         _cforge_unit_report_get_count("${REPORT_FILE}" SUITE_INDEX)
#         set(SUITE_OBJECT "{
#             \"test_suite\": \"${TEST_SUITE}\",
#             \"test_cases\": [],
#         }")
#     endif()

#     message(DEBUG "Registering case ${TEST_SUITE}.${TEST_CASE}")

#     _cforge_unit_report_get_test_case("${SUITE_OBJECT}" "${TEST_CASE}" CASE_OBJECT)
#     if(NOT CASE_OBJECT)
#         string(JSON CASE_COUNT LENGTH "${SUITE_OBJECT}" test_cases)
#         set(CASE_OBJECT "{
#             \"test_case\": \"${TEST_CASE}\",
#             \"verdict_passed\": false
#         }")
#         string(JSON SUITE_OBJECT SET "${SUITE_OBJECT}" test_cases "${CASE_COUNT}" "${CASE_OBJECT}")
#     endif()

#     string(JSON REPORT_FILE SET "${REPORT_FILE}" "${SUITE_INDEX}" "${SUITE_OBJECT}")

#     _cforge_unit_report_write_file("${REPORT_FILE}")
# endfunction()

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

    if(ARG_TEST_SCRIPT)
        get_filename_component(ARG_TEST_SCRIPT "${ARG_TEST_SCRIPT}" ABSOLUTE)
    endif()

    if(ARG_VERIFY_SCRIPT)
        get_filename_component(ARG_VERIFY_SCRIPT "${ARG_VERIFY_SCRIPT}" ABSOLUTE)
    endif()

    _cforge_unit_register_test(${ARG_TEST_SUITE} ${ARG_TEST_CASE})

    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeUnitTestRunner.cmake.in
        ${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnitTestRunner.${ARG_TEST_SUITE}.${ARG_TEST_CASE}.cmake
        @ONLY
    )
endfunction()

# function(cforge_unit_add_test_subdirectory DIRECTORY)
#     cmake_parse_arguments("ARG" "USE_CTEST" "" "" ${ARGN})

#     if(DEFINED CFORGE_UNIT_USE_CTEST)
#         set(ARG_USE_CTEST ${CFORGE_UNIT_USE_CTEST})
#     endif()

#     file(REAL_PATH "${DIRECTORY}" DIRECTORY_REAL_PATH)
#     if(NOT IS_DIRECTORY "${DIRECTORY_REAL_PATH}")
#         message(FATAL_ERROR "Not a directory")
#     endif()

#     if(ARG_USE_CTEST)
#         get_filename_component(FOLDER_NAME "${DIRECTORY_REAL_PATH}" NAME)
#         add_test(
#             NAME "${FOLDER_NAME}"
#             COMMAND ${CMAKE_COMMAND} -S "${DIRECTORY_REAL_PATH}" -B "${CMAKE_CURRENT_BINARY_DIR}/${DIRECTORY}"
#         )
#         # TODO Add logic to collect test results from cache variable
#     else()
#         add_subdirectory(${DIRECTORY})
#     endif()
# endfunction()

function(cforge_unit_run_tests)
    message(CHECK_START "Running all tests")
    foreach(SUITE IN LISTS CFORGE_UNIT_SUITES_${CFORGE_UNIT_PROJECT})
        list(APPEND CMAKE_MESSAGE_INDENT "  ")
        message(CHECK_START "Running test cases from suite ${SUITE}")
        foreach(CASE IN LISTS CFORGE_UNIT_${CFORGE_UNIT_PROJECT}__${SUITE})
            list(APPEND CMAKE_MESSAGE_INDENT "  ")
            message(CHECK_START "Running test ${SUITE}.${CASE}")
            include(${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnitTestRunner.${SUITE}.${CASE}.cmake)
            _cforge_unit_test_fn()
            if(CFORGE_UNIT_VERDICT_${CFORGE_UNIT_PROJECT}__${SUITE}__${CASE} STREQUAL failed)
                message(CHECK_FAIL "failed")
            else()
                message(CHECK_PASS "passed")
            endif()
            list(POP_BACK CMAKE_MESSAGE_INDENT)
        endforeach()
        message(CHECK_PASS "passed")
        list(POP_BACK CMAKE_MESSAGE_INDENT)
    endforeach()
    message(CHECK_PASS "passed")
endfunction()

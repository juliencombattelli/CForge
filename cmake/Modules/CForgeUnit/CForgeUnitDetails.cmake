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

macro(_cforge_unit_set_context SUITE CASE)
    # Public variables that should be in ContextCache.cmake.in
    # TODO add documentation in .rst file
    # Path to the top level of the CForge build tree for the current project
    set(CFORGE_UNIT_PROJECT_BINARY_DIR "${${CFORGE_UNIT_PROJECT}_BINARY_DIR}/CForgeUnit")
    # Test ID for the current CForge test being processed
    set(CFORGE_UNIT_CURRENT_TEST_ID "${CFORGE_UNIT_PROJECT}__${SUITE}__${CASE}")
    # Path to the build tree of the test being processed
    set(CFORGE_UNIT_CURRENT_TEST_BINARY_DIR
        "${CFORGE_UNIT_PROJECT_BINARY_DIR}/${CFORGE_UNIT_CURRENT_TEST_ID}"
    )

    # Private variables that should not be in ContextCache.cmake.in
    set(_CFORGE_UNIT_TEMPLATE_DIR "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeUnit")
    set(_CFORGE_UNIT_CURRENT_TEST_SCRIPT_DIR "${CFORGE_UNIT_CURRENT_TEST_BINARY_DIR}/scripts")
    set(_CFORGE_UNIT_CURRENT_TEST_CTEST_BINARY_DIR "${CFORGE_UNIT_CURRENT_TEST_BINARY_DIR}/build-ctest")
endmacro()

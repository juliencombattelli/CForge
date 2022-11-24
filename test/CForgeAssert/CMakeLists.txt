project(CForgeAssertTest LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH ../../cmake/Modules)
include(CForgeUnit)

cforge_unit_run_test(TEST_SUITE CForgeAssert TEST_CASE assertion_pass
    TEST_SCRIPT ./TestCaseSuccess.cmake
)

function(test_case_failure_verify VERIFY_RESULT)
    file(READ ${CFORGE_UNIT_CURRENT_ERROR_FILE} ERROR_STR)
    string(REGEX MATCH "  Assertion failed" MATCH ${ERROR_STR})
    if(NOT MATCH)
        message(SEND_ERROR "Test failed")
        set(VERIFY_RESULT 1 PARENT_SCOPE)
    endif()
endfunction()

cforge_unit_run_test(TEST_SUITE CForgeAssert TEST_CASE assertion_fail
    TEST_SCRIPT ./TestCaseFailure.cmake
    TEST_SHALL_FAIL
    VERIFY_COMMAND test_case_failure_verify
)

project(CForgeAssertTest LANGUAGES NONE) # No language to speed-up configuration time

list(APPEND CMAKE_MODULE_PATH ../../cmake/Modules)
include(CForgeUnit)

cforge_unit_run_test(TEST_SUITE CForgeAssert TEST_CASE assertion_pass
    TEST_SCRIPT ./TestCaseSuccess.cmake
)

# TODO implement
# cforge_unit_run_test(TEST_SUITE CForgeAssert TEST_CASE assertion_pass_with_message
#     TEST_SCRIPT ./TestCaseSuccessWithMessage.cmake
#     VERIFY_COMMAND <verify that `message` is not visible>
# )

function(test_case_failure_verify VERIFY_RESULT)
    file(READ ${CFORGE_UNIT_CURRENT_TEST_ERROR_FILE} ERROR_STR)
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

cforge_unit_run_test(TEST_SUITE CForgeAssert TEST_CASE assertion_fail_with_message
    TEST_SCRIPT ./TestCaseFailureWithMessage.cmake
    TEST_SHALL_FAIL
    VERIFY_SCRIPT ./TestCaseFailureWithMessage.verify.cmake
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_pass
    TEST_SCRIPT ./Success.test.cmake
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_pass_with_message
    TEST_SCRIPT ./SuccessWithMessage.test.cmake
    VERIFY_SCRIPT ./SuccessWithMessage.verify.cmake
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_fail
    TEST_SCRIPT ./Failure.test.cmake
    TEST_SHALL_FAIL
    VERIFY_SCRIPT ./Failure.verify.cmake
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_fail_with_message
    TEST_SCRIPT ./FailureWithMessage.test.cmake
    TEST_SHALL_FAIL
    VERIFY_SCRIPT ./FailureWithMessage.verify.cmake
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE missing_argument
    TEST_SCRIPT ./MissingArguments.test.cmake
    TEST_SHALL_FAIL
    VERIFY_SCRIPT ./MissingArguments.verify.cmake
)

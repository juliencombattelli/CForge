cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_pass)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_pass_with_message
    FAIL_REGEX "This shall not be seen"
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_fail
    SHALL_FAIL
    FAIL_REGEX "  Assertion failed"
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_fail_with_message
    SHALL_FAIL
    FAIL_REGEX "  Assertion failed: Variable CMAKE_NOISREV does not exist"
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE missing_argument
    SHALL_FAIL
    FAIL_REGEX "CONDITION argument is required"
)

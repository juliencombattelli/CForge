cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_pass)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_pass_with_message)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_fail
    TEST_SHALL_FAIL
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE assertion_fail_with_message
    TEST_SHALL_FAIL
)

cforge_unit_add_test(TEST_SUITE CForgeAssert TEST_CASE missing_argument
    TEST_SHALL_FAIL
)

cforge_unit_add_test(TEST_SUITE CForgeTargetAddWarnings TEST_CASE valid_profiles
    LANGUAGES C CXX
)

cforge_unit_add_test(TEST_SUITE CForgeTargetAddWarnings TEST_CASE default_profiles
    LANGUAGES C CXX
)

cforge_unit_add_test(TEST_SUITE CForgeTargetAddWarnings TEST_CASE warning_as_error
    LANGUAGES C CXX
)

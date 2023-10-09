cforge_unit_add_test(TEST_SUITE CForgeTargetEnableSanitizers TEST_CASE not_a_target
    SHALL_FAIL
    LANGUAGES C CXX
)

cforge_unit_add_test(TEST_SUITE CForgeTargetEnableSanitizers TEST_CASE not_supported_compiler
    LANGUAGES C CXX
)

cforge_unit_add_test(TEST_SUITE CForgeTargetEnableSanitizers TEST_CASE sanitizer_options_defined
    LANGUAGES C CXX
)

cforge_unit_add_test(TEST_SUITE CForgeTargetEnableSanitizers TEST_CASE sanitizers_enabled
    LANGUAGES C CXX
)

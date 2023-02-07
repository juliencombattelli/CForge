if(NOT WIN32) # Coverage not fully supported on Windows
    cforge_unit_add_test(TEST_SUITE CForgeUnit TEST_CASE coverage_no_regression)
endif()

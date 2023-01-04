include(CForgeUnit)

add_subdirectory(CForgeAssert)
add_subdirectory(CForgeTargetAddWarnings)

if(CFORGE_UNIT_REGISTERED_TESTS)
    message(STATUS "Running CForge test suite using CTest...")
    cforge_unit_run_tests()
endif()

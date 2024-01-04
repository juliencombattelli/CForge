enable_language(C CXX)

include(CForgeUnit)

add_subdirectory(CForgeAssert)
add_subdirectory(CForgeJSON)
add_subdirectory(CForgeTargetAddWarnings)
add_subdirectory(CForgeTargetEnableSanitizers)
add_subdirectory(CForgeUnit)
add_subdirectory(Packaging)

if(CFORGE_ENABLE_COVERAGE)
    find_package(LCOV REQUIRED)
    cforge_unit_add_coverage()
endif()

if(CFORGE_UNIT_REGISTERED_TESTS)
    message(STATUS "Running CForge test suite using CTest...")
    cforge_unit_run_tests()
endif()

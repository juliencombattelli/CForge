include(CForgeUnit)

cforge_unit_add_test_subdirectory(CForgeAssert USE_CTEST)


include(CForgeTargetAddWarnings)

add_library(toto INTERFACE)
cforge_target_add_warnings(toto CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/my-warnings.json")
cforge_target_add_warnings(toto)

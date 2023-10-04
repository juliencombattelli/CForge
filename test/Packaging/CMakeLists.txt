# Skip packaging tests if the binary directory is inside the source directory
# as it would lead to a infinite recursive copy of CForge build folder...
cmake_path(IS_PREFIX PROJECT_SOURCE_DIR "${PROJECT_BINARY_DIR}" IN_SOURCE_BUILD)
if(IN_SOURCE_BUILD)
    message(WARNING
        " In-source build detected.\n"
        " Packaging tests will be skipped.\n"
        " To enable them, pick a build directory outside of CForge source directory.\n"
    )
    return()
endif()

cforge_unit_add_test(TEST_SUITE Packaging TEST_CASE add_subdirectory)
cforge_unit_add_test(TEST_SUITE Packaging TEST_CASE fetchcontent)
cforge_unit_add_test(TEST_SUITE Packaging TEST_CASE cforgeconfig)

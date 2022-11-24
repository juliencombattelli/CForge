include(TestSetup.cmake)

# CMAKE_VERSION exists, so this test shall pass
cforge_assert(CONDITION CMAKE_VERSION)

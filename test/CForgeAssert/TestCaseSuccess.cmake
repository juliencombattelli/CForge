include(TestSetup.cmake)

# CMAKE_COMMAND and CMAKE_VERSION exist, so this test shall pass
cforge_assert(CONDITION CMAKE_COMMAND AND CMAKE_VERSION)

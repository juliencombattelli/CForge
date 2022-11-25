include(TestSetup.cmake)

# CMAKE_COMMAND and CMAKE_VERSION exist, so this test shall pass and message shall not be visible
cforge_assert(CONDITION CMAKE_COMMAND AND CMAKE_VERSION MESSAGE "This shall not be seen")

include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

# CMAKE_NOISREV does not exist, so this test shall fail
cforge_assert(CONDITION CMAKE_COMMAND AND CMAKE_NOISREV)

include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

add_library(TestTargetAddWarningsDefault INTERFACE)
# Just ensure the parsing of the default profile does not trigger a fatal error
cforge_target_add_warnings(TestTargetAddWarningsDefault)

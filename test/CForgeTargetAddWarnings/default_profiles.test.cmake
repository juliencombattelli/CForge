include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

add_library(TestTargetAddWarningsDefault INTERFACE)
# Do not make any assertion on this operation, just ensure the parsing of the default profile does
# not trigger a fatal error
cforge_target_add_warnings(TestTargetAddWarningsDefault)

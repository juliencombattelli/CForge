include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

add_library(TestTargetWarningAsError INTERFACE)
cforge_target_add_warnings(TestTargetWarningAsError WARNING_AS_ERROR)
get_target_property(COMPILE_WARNING_AS_ERROR TestTargetWarningAsError COMPILE_WARNING_AS_ERROR)
if(NOT COMPILE_WARNING_AS_ERROR)
    message(FATAL_ERROR "WARNING_AS_ERROR is disabled but should be enabled (${COMPILE_WARNING_AS_ERROR})")
endif()

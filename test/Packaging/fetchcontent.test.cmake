#[=============================================================================[.rst:

This test validates the FetchContent technic to import CForge.
The CForge project fetched is the local one currently under test to be sure to
test the desired revision.

#]=============================================================================]

execute_process(
    COMMAND ${CMAKE_COMMAND}
        -S ${CMAKE_CURRENT_LIST_DIR}/fetchcontent
        -B ${CMAKE_CURRENT_SOURCE_DIR}/fetchcontent-build
        -D CFORGE_DIR=${CFORGE_UNIT_PROJECT_SOURCE_DIR}
    COMMAND_ERROR_IS_FATAL ANY
)

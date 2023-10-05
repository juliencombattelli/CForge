#[=============================================================================[.rst:

This test validates the add_subdirectory technic to import CForge.
The CForge project added is the local one currently under test using a copy
to be sure to test the desired revision.

#]=============================================================================]

if(UNIX AND NOT APPLE)
    execute_process(
        COMMAND tree /home/runner/work/CForge/CForge
    )
    execute_process(
        COMMAND tree /home/runner/work/CForge/cforge-build
    )
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/add_subdirectory DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
file(COPY ${CFORGE_UNIT_PROJECT_SOURCE_DIR} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/add_subdirectory/external)

if(UNIX AND NOT APPLE)
    execute_process(
        COMMAND tree /home/runner/work/CForge/CForge
    )
    execute_process(
        COMMAND tree /home/runner/work/CForge/cforge-build
    )
endif()

execute_process(
    COMMAND ${CMAKE_COMMAND}
        -S ${CMAKE_CURRENT_SOURCE_DIR}/add_subdirectory
        -B ${CMAKE_CURRENT_SOURCE_DIR}/add_subdirectory-build
    COMMAND_ERROR_IS_FATAL ANY
)

#[=============================================================================[.rst:

This test validates the add_subdirectory technic to import CForge.
The CForge project added is the local one currently under test using a copy
to be sure to test the desired revision.

#]=============================================================================]

file(COPY ${CMAKE_CURRENT_LIST_DIR}/add_subdirectory DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
file(COPY ${CFORGE_UNIT_PROJECT_SOURCE_DIR} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/add_subdirectory/external)

# Get the actual CForge directory name
# In CI, it is usually the same name as the GitHub repository (CForge starting with capital letters)
# but on development environment it can be anything
cmake_path(GET CFORGE_UNIT_PROJECT_SOURCE_DIR FILENAME CFORGE_PROJECT_DIR_NAME)

execute_process(
    COMMAND ${CMAKE_COMMAND}
        -S ${CMAKE_CURRENT_SOURCE_DIR}/add_subdirectory
        -B ${CMAKE_CURRENT_SOURCE_DIR}/add_subdirectory-build
        -D CFORGE_PROJECT_DIR_NAME=${CFORGE_PROJECT_DIR_NAME}
    COMMAND_ERROR_IS_FATAL ANY
)

#[=============================================================================[.rst:

This test validates the find_package() technic to import CForge.
The CForge project fetched is the local one currently under test to be sure to
test the desired revision.

#]=============================================================================]

include(FetchContent)

FetchContent_Declare(
    cforge
    URL ${CFORGE_UNIT_PROJECT_SOURCE_DIR}
)
FetchContent_Populate(cforge) # Only populate as we don't want to do an add_subdirectory() of CForge

execute_process(
    COMMAND ${CMAKE_COMMAND}
        -S ${cforge_SOURCE_DIR}
        -B ${cforge_BINARY_DIR}
        -D CMAKE_INSTALL_PREFIX=${FETCHCONTENT_BASE_DIR}/cforge-install
    COMMAND_ERROR_IS_FATAL ANY
)

execute_process(
    COMMAND ${CMAKE_COMMAND}
        --build ${cforge_BINARY_DIR}
        --target all install
    COMMAND_ERROR_IS_FATAL ANY
)

# Configure and run the test project using CMAKE_PREFIX_PATH to locate CForge module
execute_process(
    COMMAND ${CMAKE_COMMAND}
        -S ${CMAKE_CURRENT_LIST_DIR}/cforgeconfig
        -B ${CMAKE_CURRENT_SOURCE_DIR}/cforgeconfig-build-with-prefix-path
        -D CMAKE_PREFIX_PATH=${FETCHCONTENT_BASE_DIR}/cforge-install
    COMMAND_ERROR_IS_FATAL ANY
)

# Configure and run the test project using CForge_DIR to locate CForge module
execute_process(
    COMMAND ${CMAKE_COMMAND}
        -S ${CMAKE_CURRENT_LIST_DIR}/cforgeconfig
        -B ${CMAKE_CURRENT_SOURCE_DIR}/cforgeconfig-build-with-cforge-dir
        -D CForge_DIR=${FETCHCONTENT_BASE_DIR}/cforge-install/lib/cmake/CForge
    COMMAND_ERROR_IS_FATAL ANY
)

cmake_minimum_required(VERSION 3.21)
set(PROJECT_AUTHOR "Julien Combattelli")
project(CForge
    VERSION 1.0.0
    DESCRIPTION "A collection of CMake scripts and modules to forge robust and toolable build systems "
    HOMEPAGE_URL "https://github.com/juliencombattelli/CForge"
)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)
# Propagate CForge module path to parent project if any
if(NOT CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
endif()

################################################################################
### Options definition
################################################################################

include(CMakeDependentOption)

option(CFORGE_ENABLE_TESTING "Download GoogleTest and enable the unit test suite execution" ${PROJECT_IS_TOP_LEVEL})
cmake_dependent_option(CFORGE_ENABLE_TESTING_AT_CONF "Run test suite at configuration instead of during CTest phase" OFF CFORGE_ENABLE_TESTING OFF)
cmake_dependent_option(CFORGE_ENABLE_COVERAGE "Enable test coverage report generation" OFF CFORGE_ENABLE_TESTING OFF)
option(CFORGE_ENABLE_DOCUMENTATION "Generate the html documentation using Sphinx" OFF)
option(CFORGE_ENABLE_CPACK "Enable packaging using CPack" ${PROJECT_IS_TOP_LEVEL})

# Disable CPack for in-source build/install
if(CFORGE_ENABLE_CPACK AND (CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR))
    cmake_path(IS_PREFIX PROJECT_SOURCE_DIR "${PROJECT_BINARY_DIR}" IN_SOURCE_BUILD)
    if(IN_SOURCE_BUILD)
        message(WARNING "In-source build detected.")
    endif()
    cmake_path(IS_PREFIX PROJECT_SOURCE_DIR "${CMAKE_INSTALL_PREFIX}" IN_SOURCE_INSTALL)
    if(IN_SOURCE_INSTALL)
        message(WARNING "In-source install detected.")
    endif()
    if(IN_SOURCE_BUILD OR IN_SOURCE_INSTALL)
        message(WARNING
            " In-source build/install are highly discouraged as it would result in packaging the build/install directories.\n"
            " Disabling CPack."
        )
        set(CFORGE_ENABLE_CPACK FALSE)
    endif()
endif()

################################################################################
### CForge test handling
################################################################################

if(CFORGE_ENABLE_TESTING)
    include(CTest)
    set(${CFORGE_PROJECT_PREFIX}_UNIT_RUN_TESTS_AT_CONFIGURATION ${CFORGE_ENABLE_TESTING_AT_CONF} CACHE INTERNAL "" FORCE)
    add_subdirectory(test)
endif()

################################################################################
### CForge documentation handling
################################################################################

if(CFORGE_ENABLE_DOCUMENTATION)
    add_subdirectory(doc)
endif()

################################################################################
### Package config file generation
################################################################################

include(GNUInstallDirs)

set(ConfigPackageLocation ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

# Generate CMake package config file
include(CMakePackageConfigHelpers)
configure_package_config_file(
    ${PROJECT_SOURCE_DIR}/cmake/Config/${PROJECT_NAME}Config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/Config/${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION ${ConfigPackageLocation}
)

# Generate CMake package config version file
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/cmake/Config/${PROJECT_NAME}ConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

################################################################################
### CForge library installation
################################################################################

# Install the CMake scripts
install(
    DIRECTORY ${PROJECT_SOURCE_DIR}/cmake/Modules
    DESTINATION ${ConfigPackageLocation}
)

# Install the package config and version files
install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/cmake/Config/${PROJECT_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/cmake/Config/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION ${ConfigPackageLocation}
)

# Prevent installation if the install prefix is a subdir of CForge project root dir
# Augment the check above disabling CPack to cover the case where cmake --install --prefix is used
install(CODE "set(CFORGE_SOURCE_DIR \"${PROJECT_SOURCE_DIR}\")")
install(CODE [[
    file(REAL_PATH "${CMAKE_INSTALL_PREFIX}" CMAKE_INSTALL_PREFIX EXPAND_TILDE)
    cmake_path(IS_PREFIX CFORGE_SOURCE_DIR "${CMAKE_INSTALL_PREFIX}" IN_SOURCE_INSTALL)
    if(IN_SOURCE_INSTALL)
        message(SEND_ERROR
            " In-source install detected.\n"
            " In-source install is prevented as it would result in packaging the install directories for CPack source package.\n"
            " Exiting now."
        )
    endif()
]])

################################################################################
### CPack config files generation
################################################################################

if(CFORGE_ENABLE_CPACK)
    include(CPack)
endif()

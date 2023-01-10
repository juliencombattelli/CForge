cmake_minimum_required(VERSION 3.16) # TODO Should be equal to smaller required version of provided modules
set(PROJECT_AUTHOR "Julien Combattelli")
project(CForge
    VERSION 1.0.0
    DESCRIPTION "A collection of CMake scripts and modules to forge robust and toolable build systems "
    HOMEPAGE_URL "https://github.com/juliencombattelli/CForge"
)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

include(CMakeDependentOption)

option(CFORGE_ENABLE_TESTING "Download GoogleTest and enable the unit test suite execution" ON)
cmake_dependent_option(CFORGE_ENABLE_COVERAGE "Enable test coverage report generation" OFF CFORGE_ENABLE_TESTING OFF)
option(CFORGE_ENABLE_DOCUMENTATION "Generate the html documentation using Sphinx" OFF)

if(CFORGE_ENABLE_TESTING)
    include(CTest)
    add_subdirectory(test)
endif()

if(CFORGE_ENABLE_DOCUMENTATION)
    include(CForgeDoc)
    cforge_add_documentation(doc CONF_FILE doc/conf.py)
endif()

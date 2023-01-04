cmake_minimum_required(VERSION 3.16)
project(cforge)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

include(CMakeDependentOption)

option(CFORGE_ENABLE_TESTING "Download GoogleTest and enable the unit test suite execution" ON)
cmake_dependent_option(CFORGE_ENABLE_COVERAGE "Enable test coverage report generation" OFF CFORGE_ENABLE_TESTING OFF)

if(CFORGE_ENABLE_TESTING)
    include(CTest)
    add_subdirectory(test)
endif()

# TODO add doc generation targets based on https://gitlab.com/Pro1/doxygen-cmake-sphinx

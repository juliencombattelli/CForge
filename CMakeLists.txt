cmake_minimum_required(VERSION 3.16)
project(cforge)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

# TODO Add testing option
include(CTest)
enable_testing()
add_subdirectory(test)

# TODO add documentation capability based on https://gitlab.com/Pro1/doxygen-cmake-sphinx

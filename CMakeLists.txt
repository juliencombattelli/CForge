cmake_minimum_required(VERSION 3.16)
project(cforge-tests)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

add_subdirectory(test)

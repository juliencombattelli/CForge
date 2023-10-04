cmake_minimum_required(VERSION 3.20)
project(cforge_packaging_cforgeconfig LANGUAGES NONE)

find_package(CForge CONFIG REQUIRED)

if(COMMAND cforge_assert)
    message(SEND_ERROR "CForge functions are wrongly imported without a proper include()")
endif()

include(CForgeAssert)

if(NOT COMMAND cforge_assert)
    message(SEND_ERROR "CForge functions are not imported even with the appropriate include()")
endif()

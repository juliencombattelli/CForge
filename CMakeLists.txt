cmake_minimum_required(VERSION 3.16)
project(cforge)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

if($CACHE{RUN_COVERAGE})
    #
    include(GenerateCoverageReport.cmake)
    cforge_unit_coverage_generate_coverage_report(${CMAKE_BINARY_DIR})
    return()
endif()


set(VAR "a;c;b") #[==[ Hello ]==] #[===[
hello
 <- this is not the closing
]

]===]

if(UNIX)
    if(APPLE)
        message("")
    elseif()
        message("")
    else()
        message("")
    endif()
else()
    message("")
endif()

# TODO Add testing option
include(CTest) #[==[ Hello ]==]

#[==[ Hello ]==] #[=[
    message("")
]=]

enable_testing()
#[==[ Hello ]==]
add_subdirectory(test)



# TODO add doc generation targets based on https://gitlab.com/Pro1/doxygen-cmake-sphinx

# set(TRACEFILE ${CMAKE_SOURCE_DIR}/trace.txt CACHE INTERNAL "")
# set(LCOV_OUTPUT ${CMAKE_SOURCE_DIR}/output_lcov.txt CACHE INTERNAL "")
# include(cmake/Modules/CForgeUnit/CMakeTraceToLCov.cmake)

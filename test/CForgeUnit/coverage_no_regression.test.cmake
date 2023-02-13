include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/TestProject)
execute_process(
    COMMAND ${CMAKE_COMMAND}
        -S ${CMAKE_CURRENT_LIST_DIR}/TestProject
        -B ${CMAKE_CURRENT_BINARY_DIR}/TestProject/build
        --trace --trace-redirect=${CMAKE_CURRENT_BINARY_DIR}/TestProject/cforge-unit-coverage-traces.txt
)

find_package(LCOV REQUIRED)
cforge_unit_coverage_generate_coverage_report(
    SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/TestProject"
    BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/TestProject"
    RESULT_VAR OUTPUT
)

cforge_assert(CONDITION OUTPUT STREQUAL "line:76.9 branch:42.9"
    MESSAGE "Results for control file changed. Have you updated the control file recently?"
)

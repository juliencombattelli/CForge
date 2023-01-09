include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/TestProject)
execute_process(
    COMMAND ${CMAKE_COMMAND}
        -S ${CMAKE_CURRENT_LIST_DIR}/TestProject
        -B ${CMAKE_CURRENT_BINARY_DIR}/TestProject/build
        --trace --trace-redirect=${CMAKE_CURRENT_BINARY_DIR}/TestProject/cforge-unit-coverage-traces.txt
)

cforge_unit_coverage_generate_coverage_report(${CFORGE_UNIT_PROJECT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/TestProject)
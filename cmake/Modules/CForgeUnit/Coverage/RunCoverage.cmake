include(${CMAKE_CURRENT_LIST_DIR}/GenerateCoverageReport.cmake)

find_package(LCOV REQUIRED)
cforge_unit_coverage_generate_coverage_report(${CFORGE_UNIT_PROJECT_SOURCE_DIR} ${CFORGE_UNIT_PROJECT_BINARY_DIR} OUTPUT)

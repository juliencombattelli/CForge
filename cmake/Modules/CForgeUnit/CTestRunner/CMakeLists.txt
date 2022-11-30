cmake_minimum_required(VERSION 3.20)
project(_cforge_unit_ctest_runner_project LANGUAGES NONE)

include(CForgeUnit)
include($CACHE{CFORGE_UNIT_CURRENT_TEST_BINARY_DIR}/scripts/RunTest.cmake)
_cforge_unit_run_test()

if(CFORGE_UNIT_VERDICT_${CFORGE_UNIT_CURRENT_TEST_ID} STREQUAL failed)
    message(FATAL_ERROR "Test ${CFORGE_UNIT_CURRENT_TEST_ID} failed")
else()
    message(STATUS "Test ${CFORGE_UNIT_CURRENT_TEST_ID} passed")
endif()

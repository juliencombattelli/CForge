cmake_minimum_required(VERSION 3.20)
project(_cforge_unit_ctest_registrar_project LANGUAGES NONE)

include(CTest)

foreach(TEST IN LISTS CFORGE_UNIT_REGISTERED_TESTS)
    include(${CFORGE_UNIT_PROJECT_BINARY_DIR}/Registrar/CForgeUnitRegisterTest.${TEST}.cmake)
endforeach()

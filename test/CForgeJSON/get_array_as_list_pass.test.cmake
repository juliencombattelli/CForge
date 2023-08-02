include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

cforge_json_get_array_as_list(
    RESULT_VARIABLE MEMBER_STRING
    JSON ""
    MEMBER abc
)
cforge_assert_that(string MEMBER_STRING is_empty)

cforge_json_get_array_as_list(
    RESULT_VARIABLE MEMBER_STRING
    JSON [[ {"key": "value1"} ]]
    MEMBER key
)
cforge_assert(CONDITION MEMBER_STRING STREQUAL "value1")

cforge_json_get_array_as_list(
    RESULT_VARIABLE MEMBER_STRING
    JSON [[ {"key": "value2"} ]]
    MEMBER key
)
cforge_assert(CONDITION MEMBER_STRING STREQUAL "value2")

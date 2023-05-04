include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

cforge_json_get_array_as_list(RESULT_VARIABLE MEMBER_STRING JSON "" MEMBER abc)
cforge_assert_that(string MEMBER_STRING is_empty)

include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

# Path to a single member
cforge_json_member_as_string(RESULT_VARIABLE MEMBER_STRING MEMBER abc)
cforge_assert(CONDITION MEMBER_STRING STREQUAL "#/abc")

# Path to an index in an array
cforge_json_member_as_string(RESULT_VARIABLE MEMBER_STRING MEMBER 2)
cforge_assert(CONDITION MEMBER_STRING STREQUAL "#/2")

# Path to a nested element ending with an array index
cforge_json_member_as_string(RESULT_VARIABLE MEMBER_STRING MEMBER abc def 2)
cforge_assert(CONDITION MEMBER_STRING STREQUAL "#/abc/def/2")

# Path to a nested element ending with a member
cforge_json_member_as_string(RESULT_VARIABLE MEMBER_STRING MEMBER abc def 2 ghijkl 42 mno)
cforge_assert(CONDITION MEMBER_STRING STREQUAL "#/abc/def/2/ghijkl/42/mno")

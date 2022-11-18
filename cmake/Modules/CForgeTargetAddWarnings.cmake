# string(JSON) introduced in CMake 3.19
cmake_minimum_required(VERSION 3.19)

#[[

JSON config file format:

{
    "version": "int",
    "base_profiles": [],
    "profiles": []
}

Base profile object format:
{
    "name": "string",
    "inherit": "string" or ["strings"], // optional
    "warnings": ["strings"]
}

Profile object format:
{
    "compiler_id": "string",
    "inherit": "string" or ["strings"], // optional
    "warnings": ["strings"]
}

If a base profile defines a "name", it must be unique.

"compiler_id" must be a valid CMake compiler identification string:
See https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html.

"inherit" must be (or contain) a base profile name defined in the document.

"warnings" strings may use CMake generator expressions.

#]]

function(_use_default_warning_config_file_if_arg_not_set CONFIG_FILE)
    if(NOT ${CONFIG_FILE})
        set(USE_DEFAULT_CONFIG ON)
    elseif(NOT EXISTS ${${CONFIG_FILE}})
        message(WARNING "${${CONFIG_FILE}} does not exist. Using default config file.")
        set(USE_DEFAULT_CONFIG ON)
    endif()
    if(USE_DEFAULT_CONFIG)
        set(${CONFIG_FILE} ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/default-warnings.json PARENT_SCOPE)
    endif()
endfunction()

#[[

    cforge_json_get_array_as_list(<out-var> <json-string> <member|index> [<member|index> ...])

Get an array from <json-string> at the location given by the list of <member|index> arguments
and copy its elements into the list variable <out-var>.
If the JSON element designated by the <member|index> arguments is not an array but a single value,
the <out-var> list will only contain that value.
TODO test how OBJECTs are handled with the current implementation.
If the JSON element is not found, the returned list <out-var> will be empty.

#]]
function(cforge_json_get_array_as_list)
    cmake_parse_arguments("ARG" "OPTIONAL" "RESULT_VARIABLE;JSON" "MEMBER" ${ARGN})

    if(ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "All non-boolean arguments are required")
    endif()

    unset(${ARG_RESULT_VARIABLE})

    if(ARG_OPTIONAL)
        string(JSON MEMBER_TYPE ERROR_VARIABLE ERROR TYPE ${ARG_JSON} ${ARG_MEMBER})
    else()
        string(JSON MEMBER_TYPE TYPE ${ARG_JSON} ${ARG_MEMBER})
    endif()

    if(NOT ERROR)
        if(MEMBER_TYPE STREQUAL "ARRAY" OR MEMBER_TYPE STREQUAL "OBJECT")
            string(JSON ARRAY_LEN LENGTH ${ARG_JSON} ${ARG_MEMBER})
            if(ARRAY_LEN GREATER 0)
                math(EXPR ARRAY_LAST "${ARRAY_LEN} - 1")
                foreach(IDX RANGE ${ARRAY_LAST})
                    string(JSON ARRAY_ITEM GET ${ARG_JSON} ${ARG_MEMBER} ${IDX})
                    list(APPEND ${ARG_RESULT_VARIABLE} ${ARRAY_ITEM})
                endforeach()
            endif()
        else()
            string(JSON SINGLE_ITEM GET ${ARG_JSON} ${ARG_MEMBER})
            list(APPEND ${ARG_RESULT_VARIABLE} ${SINGLE_ITEM})
        endif()
    endif()
    set(${ARG_RESULT_VARIABLE} ${${ARG_RESULT_VARIABLE}} PARENT_SCOPE)
endfunction()

function(cforge_target_add_warnings TARGET_NAME)
    cmake_parse_arguments("ARG" "WARNING_AS_ERROR" "CONFIG_FILE" "" ${ARGN})

    _use_default_warning_config_file_if_arg_not_set(ARG_CONFIG_FILE)

    message(CHECK_START "Parsing warning config from file ${ARG_CONFIG_FILE}")
    file(READ ${ARG_CONFIG_FILE} CONFIG_STRING)
    list(APPEND CMAKE_MESSAGE_INDENT "  ")

    string(JSON VERSION GET ${CONFIG_STRING} version)
    message(STATUS "Version: ${VERSION}")

    # TODO parse base profiles first

    string(JSON PROFILE_COUNT LENGTH ${CONFIG_STRING} profiles)
    math(EXPR PROFILE_LAST "${PROFILE_COUNT} - 1")
    foreach(IDX RANGE ${PROFILE_LAST})
        list(APPEND CMAKE_MESSAGE_INDENT "  ")
            string(JSON COMPILER_ID GET ${CONFIG_STRING} profiles ${IDX} compiler_id)
            if(COMPILER_ID MATCHES "${CMAKE_CXX_COMPILER_ID}")
                message(STATUS "Compiler ID: ${COMPILER_ID}")
                cforge_json_get_array_as_list(
                    RESULT_VARIABLE INHERITED_PROFILES
                    JSON ${CONFIG_STRING}
                    MEMBER profiles ${IDX} inherit
                )
                foreach(INHERITED_PROFILE IN LISTS INHERITED_PROFILES)
                    message(STATUS "Searching for base profile ${INHERITED_PROFILE}")
                    string(JSON BASE_PROFILE_COUNT LENGTH ${CONFIG_STRING} base_profiles) # Compute once
                    math(EXPR BASE_PROFILE_LAST "${BASE_PROFILE_COUNT} - 1")
                    foreach(IDX2 RANGE ${BASE_PROFILE_LAST})
                        string(JSON BASE_PROFILE_NAME GET ${CONFIG_STRING} base_profiles ${IDX2} name)
                        if(BASE_PROFILE_NAME STREQUAL INHERITED_PROFILE)
                            message(STATUS "Base profile ${INHERITED_PROFILE} found")
                            cforge_json_get_array_as_list(
                                RESULT_VARIABLE INHERITED_PROFILE_WARNINGS
                                JSON ${CONFIG_STRING}
                                MEMBER base_profiles ${IDX2} warnings
                            )
                            list(APPEND WARNINGS ${INHERITED_PROFILE_WARNINGS})
                            set(BASE_PROFILE_FOUND YES)
                            break()
                        endif()
                    endforeach()
                    if(NOT BASE_PROFILE_FOUND)
                        message(WARNING "Inherited base profile not found: ${INHERITED_PROFILE}")
                    endif()
                endforeach()
                cforge_json_get_array_as_list(
                    RESULT_VARIABLE PROFILE_WARNINGS
                    JSON ${CONFIG_STRING}
                    MEMBER profiles ${IDX} warnings
                )
                list(APPEND WARNINGS ${PROFILE_WARNINGS})
                list(POP_BACK CMAKE_MESSAGE_INDENT)
                break()
            endif()
        list(POP_BACK CMAKE_MESSAGE_INDENT)
    endforeach()

    message(NOTICE "Warnings: ${WARNINGS}")

    list(POP_BACK CMAKE_MESSAGE_INDENT)
    if(ERROR_CODE)
        message(CHECK_FAIL "failed: ${ERROR_MESSAGE}")
    else()
        message(CHECK_PASS "done")
    endif()

endfunction()

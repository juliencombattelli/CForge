# string(JSON) introduced in CMake 3.19
cmake_minimum_required(VERSION 3.19)

#[[

#]]
function(cforge_json_member_as_string)
    cmake_parse_arguments("ARG" "" "RESULT_VARIABLE" "MEMBER" ${ARGN})
    if(ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "All arguments are required")
    endif()
    foreach(MEMBER IN LISTS ARG_MEMBER)
        if (MEMBER MATCHES "^[0-9]+$")
            set(MEMBER_PATH "${MEMBER_PATH}[${MEMBER}]")
        else()
            set(MEMBER_PATH "${MEMBER_PATH}.${MEMBER}")
        endif()
    endforeach()
    string(SUBSTRING "${MEMBER_PATH}" 1 -1 MEMBER_PATH) # Remove leading `.`
    set(${ARG_RESULT_VARIABLE} "${MEMBER_PATH}" PARENT_SCOPE)
endfunction()

#[[

    cforge_json_get_array_as_list(<out-var> <json-string> <member|index> [<member|index> ...])

Get an array from <json-string> at the location given by the list of <member|index> arguments
and copy its elements into the list variable <out-var>.
If the JSON element designated by the <member|index> arguments is not an array but a single value,
the <out-var> list will only contain that value.
If the JSON element is not found and the OPTIONAL boolean argument is used, then the returned list
<out-var> will be empty. Otherwise a fatal error is thrown.

TODO Test how OBJECTs are handled with the current implementation.

#]]
function(cforge_json_get_array_as_list)
    cmake_parse_arguments("ARG" "OPTIONAL" "RESULT_VARIABLE;JSON" "MEMBER" ${ARGN})

    if(ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "All non-boolean arguments are required")
    endif()

    unset(${ARG_RESULT_VARIABLE})

    string(JSON MEMBER_TYPE ERROR_VARIABLE ERROR TYPE ${ARG_JSON} ${ARG_MEMBER})

    if(NOT ARG_OPTIONAL AND ERROR)
        cforge_json_member_as_string(RESULT_VARIABLE MEMBER_PATH MEMBER ${ARG_MEMBER})
        message(FATAL_ERROR
            " \n"
            " Fatal error looking for JSON member '${MEMBER_PATH}':\n"
            "   ${ERROR}\n"
        )
    elseif(NOT ERROR)
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

#[=======================================================================[.rst:
CForgeJSON
----------

This module provides functions for parsing JSON strings in CMake scripts using
:cmake:command:`string(JSON)`.

.. note:: requires CMake 3.19 or greater
#]=======================================================================]

# string(JSON) introduced in CMake 3.19
cmake_minimum_required(VERSION 3.19)

include_guard(GLOBAL)

include(CForgeAssert)

#[=======================================================================[.rst:
.. cmake:command:: cforge_json_member_as_string

  Convert a CMake JSON member list into a more readable fragment identifier based on
  JSON Pointers (RFC6901). Named members will add ``/member``, whereas indexes will
  add a ``/index`` to the result variable. The identifier will start with # to denote
  the root.

  .. code-block:: cmake

    cforge_json_member_as_string(
        RESULT_VARIABLE <out-var>
        MEMBER <member|index> [<member|index> ...]
    )

  **Usage example**

  .. code-block:: cmake

    cforge_json_member_as_string(
        RESULT_VARIABLE MEMBER_STRING
        MEMBER abc def 2 ghi
    )

  The member list ``abc def 2 ghi`` will be converted into ``#/abc/def/2/ghi`` and stored into
  ``MEMBER_STRING`` result variable.

#]=======================================================================]
function(cforge_json_member_as_string)
    cmake_parse_arguments("ARG" "" "RESULT_VARIABLE" "MEMBER" ${ARGN})
    cforge_assert(CONDITION ARG_RESULT_VARIABLE AND ARG_MEMBER MESSAGE "Missing required argument")
    set(MEMBER_PATH "#")
    if(ARG_MEMBER)
        foreach(MEMBER IN LISTS ARG_MEMBER)
            set(MEMBER_PATH "${MEMBER_PATH}/${MEMBER}")
        endforeach()
    endif()
    set(${ARG_RESULT_VARIABLE} "${MEMBER_PATH}" PARENT_SCOPE)
endfunction()

#[=======================================================================[.rst:
.. cmake:command:: cforge_json_get_array_as_list

  Get an array from ``<json-string>`` at the location given by the list of ``<member|index>``
  arguments and copy its elements into the list variable ``<out-var>``.

  .. code-block:: cmake

    cforge_json_get_array_as_list(
        RESULT_VARIABLE <out-var>
        JSON <json-string>
        MEMBER <member|index> [<member|index> ...]
        [OPTIONAL]
    )

  If the JSON element designated by the ``<member|index>`` arguments is not an array but a single
  value, the ``<out-var>`` list will only contain that value.

  If the values are JSON objects, the whole objects will be stored in the list ``<out-var>``
  for later processing.

  If the JSON element designated by the ``<member|index>`` arguments is not found and the ``OPTIONAL``
  boolean argument is used, then the returned list ``<out-var>`` will be empty.
  Otherwise a fatal error is thrown.

  **Parameters**

  ``OPTIONAL``
    Do not throw an error if the JSON member is not found.

  **Usage example**

  .. code-block:: cmake

    cforge_json_get_array_as_list(
        ...
    )

  Desc

#]=======================================================================]
function(cforge_json_get_array_as_list)
    cmake_parse_arguments("ARG" "OPTIONAL" "RESULT_VARIABLE;JSON" "MEMBER" ${ARGN})

    cforge_assert(CONDITION ARG_RESULT_VARIABLE MESSAGE "Missing required argument: RESULT_VARIABLE")
    cforge_assert(CONDITION ARG_MEMBER MESSAGE "Missing required argument: MEMBER")

    set(${ARG_RESULT_VARIABLE} "")

    if(NOT ARG_JSON)
        # If JSON string is not provided or empty, return an empty list
        set(${ARG_RESULT_VARIABLE} "${${ARG_RESULT_VARIABLE}}" PARENT_SCOPE)
        return()
    endif()

    string(JSON MEMBER_TYPE ERROR_VARIABLE ERROR TYPE ${ARG_JSON} ${ARG_MEMBER})

    if(NOT ARG_OPTIONAL AND ERROR)
        cforge_json_member_as_string(RESULT_VARIABLE MEMBER_PATH MEMBER ${ARG_MEMBER})
        message(FATAL_ERROR
            " \n"
            " Fatal error looking for JSON member '${MEMBER_PATH}':\n"
            "   ${ERROR}\n"
        )
    elseif(NOT ERROR)
        if(MEMBER_TYPE STREQUAL "ARRAY")
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
    return()
endfunction()

# TODO Find if in array

# TODO doc
function(cforge_json_append)
    cmake_parse_arguments("ARG" "" "OUT;JSON;VALUE;INDEX" "MEMBER" ${ARGN})
    # TODO Add argument checking
    # TODO Add member type checking
    string(JSON LIST_LENGTH LENGTH "${ARG_JSON}" ${ARG_MEMBER})
    string(JSON "${ARG_OUT}" SET "${ARG_JSON}" ${ARG_MEMBER} ${LIST_LENGTH} "${ARG_VALUE}")
    set(${ARG_OUT} ${${ARG_OUT}} PARENT_SCOPE)
    if(ARG_INDEX)
        set(${ARG_INDEX} ${LIST_LENGTH} PARENT_SCOPE)
    endif()
endfunction()

# TODO Set_or_append to array

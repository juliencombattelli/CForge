# string(JSON) introduced in CMake 3.19
cmake_minimum_required(VERSION 3.19)

#[=======================================================================[.rst:
CForgeTargetAddWarnings
-----------------------

Add some warnings from a JSON config file to a CMake target.

.. command:: cforge_json_member_as_string

  .. code-block:: cmake

    cforge_target_add_warnings(<target-name>
        [CONFIG_FILE <config-file>]
        [WARNING_AS_ERROR]
    )

If the ``CONFIG_FILE`` argument is not specified, the default config file
cmake/Modules/default-warnings.cmake will be used. This file provides a reasonable set of warnings
for GCC, Clang and MSVC that should be enabled in all projects.

The ``WARNING_AS_ERROR`` optional argument turns warnings into errors.
TODO This is not implemented for now. Using it will cause a configuration warning.
     It may be implemented using COMPILE_WARNING_AS_ERROR target property, requiring CMake 3.24+.

JSON config file format
^^^^^^^^^^^^^^^^^^^^^^^

Header format
"""""""""""""
{
    "version": <int>,
    "base_profiles": [<base profile object>, ...],
    "profiles": [<profile object>, ...]
}

Base profile object format
""""""""""""""""""""""""""
{
    "name": <string>,
    "inherit": [<string>, ...], // optional
    "warnings": [<string>, ...]
}

Profile object format
"""""""""""""""""""""
{
    "compiler_id": <string>,
    "inherit": [<string> or <cross-file inheritance object>, ...], // optional
    "warnings": [<string>, ...]
}

Cross-file inheritance object format
""""""""""""""""""""""""""""""""""""
{
    "base_profiles": [<string>, ...],
    "file": <string>
}

Fields description
""""""""""""""""""

If a base profile defines a "name", it must be unique.
TODO There is no check on that currently. When looking for a base profile name, the parser stops
     after finding the first one.

"compiler_id" must be a valid CMake compiler identification string.
See https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html.

"inherit" must contain base profile names defined in the same document or objects grouping profile names and their
definition file.

"warnings" strings may use CMake generator expressions.

TODO remove capability to use a single element instead of an array. Should simplify the parsing.

#]=======================================================================]

include_guard(GLOBAL)

include(CForgeJSON)

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

function(_is_in_file_base_profile BASE_PROFILE RESULT)
    string(JSON TYPE ERROR_VARIABLE _ TYPE ${BASE_PROFILE})
    # _ is used to avoid a fatal error for in-file profiles that are simple strings, not valid JSON strings
    if(TYPE STREQUAL "OBJECT")
        set(${RESULT} FALSE PARENT_SCOPE)
    else()
        set(${RESULT} TRUE PARENT_SCOPE)
    endif()
endfunction()

function(_parse_in_file_base_profiles_version_1 CONFIG_STRING INHERITED_PROFILE)
    string(JSON BASE_PROFILE_COUNT LENGTH "${CONFIG_STRING}" base_profiles)
    math(EXPR BASE_PROFILE_LAST "${BASE_PROFILE_COUNT} - 1")
    foreach(IDX RANGE ${BASE_PROFILE_LAST})
        string(JSON BASE_PROFILE_NAME GET ${CONFIG_STRING} base_profiles ${IDX} name)
        if(BASE_PROFILE_NAME STREQUAL INHERITED_PROFILE)
            message(DEBUG "Base profile ${INHERITED_PROFILE} found")
            cforge_json_get_array_as_list(
                RESULT_VARIABLE INHERITED_PROFILE_WARNINGS
                JSON "${CONFIG_STRING}"
                MEMBER base_profiles ${IDX} warnings
            )
            list(APPEND WARNINGS ${INHERITED_PROFILE_WARNINGS})
            set(BASE_PROFILE_FOUND YES)
            set(BASE_PROFILE_FOUND ${BASE_PROFILE_FOUND} PARENT_SCOPE)
            break()
        endif()
    endforeach()
    set(WARNINGS "${WARNINGS}" PARENT_SCOPE)
endfunction()

function(_parse_out_of_file_base_profiles_version_1 INHERITED_PROFILE)
    # TODO support multiple profiles for one file
    string(JSON BASE_PROFILE_NAME GET "${INHERITED_PROFILE}" name)
    string(JSON FILE_NAME GET "${INHERITED_PROFILE}" file)
    get_filename_component(FILE_NAME "${FILE_NAME}" ABSOLUTE)
    message(DEBUG "Base profile ${BASE_PROFILE_NAME} in ${FILE_NAME}")
    if(NOT EXISTS "${FILE_NAME}")
        message(FATAL_ERROR "Error searching base profile ${BASE_PROFILE_NAME}: file ${FILE_NAME} not found")
    endif()
    file(READ "${FILE_NAME}" OTHER_CONFIG_STRING)
    _parse_base_profiles_version_1("${OTHER_CONFIG_STRING}" ${BASE_PROFILE_NAME})
    set(BASE_PROFILE_FOUND ${BASE_PROFILE_FOUND} PARENT_SCOPE)
endfunction()

function(_parse_base_profiles_version_1 CONFIG_STRING INHERITED_PROFILES)
    string(JSON BASE_PROFILE_COUNT LENGTH ${CONFIG_STRING} base_profiles)
    math(EXPR BASE_PROFILE_LAST "${BASE_PROFILE_COUNT} - 1")
    foreach(INHERITED_PROFILE IN LISTS INHERITED_PROFILES)
        message(DEBUG "Searching for base profile ${INHERITED_PROFILE}")
        _is_in_file_base_profile(${INHERITED_PROFILE} IS_IN_FILE)
        message(DEBUG "Base profile defined locally: ${IS_IN_FILE}")
        if(IS_IN_FILE)
            _parse_in_file_base_profiles_version_1("${CONFIG_STRING}" "${INHERITED_PROFILE}")
            set(BASE_PROFILE_FOUND ${BASE_PROFILE_FOUND} PARENT_SCOPE)
        else()
            _parse_out_of_file_base_profiles_version_1("${INHERITED_PROFILE}")
        endif()
        if(NOT BASE_PROFILE_FOUND)
            message(WARNING "Inherited base profile not found: ${INHERITED_PROFILE}")
        endif()
    endforeach()
    set(WARNINGS ${WARNINGS} PARENT_SCOPE)
endfunction()

function(_parse_warning_config_version_1 CONFIG_STRING)
    string(JSON PROFILE_COUNT LENGTH ${CONFIG_STRING} profiles)
    math(EXPR PROFILE_LAST "${PROFILE_COUNT} - 1")
    foreach(IDX RANGE ${PROFILE_LAST})
        string(JSON COMPILER_ID GET ${CONFIG_STRING} profiles ${IDX} compiler_id)
        message(DEBUG "Compiler ID: ${COMPILER_ID}")
        if(NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES ${COMPILER_ID})
            message(DEBUG "Compiler ID: ${COMPILER_ID} - does not match")
        else()
            message(DEBUG "Compiler ID: ${COMPILER_ID} - matches")
            list(APPEND CMAKE_MESSAGE_INDENT "  ")
            cforge_json_get_array_as_list(
                RESULT_VARIABLE INHERITED_PROFILES
                JSON ${CONFIG_STRING}
                MEMBER profiles ${IDX} inherit
                OPTIONAL
            )
            _parse_base_profiles_version_1("${CONFIG_STRING}" "${INHERITED_PROFILES}")
            cforge_json_get_array_as_list(
                RESULT_VARIABLE PROFILE_WARNINGS
                JSON ${CONFIG_STRING}
                MEMBER profiles ${IDX} warnings
            )
            list(APPEND WARNINGS ${PROFILE_WARNINGS})
            list(POP_BACK CMAKE_MESSAGE_INDENT)
            break()
        endif()
    endforeach()
    set(WARNINGS ${WARNINGS} PARENT_SCOPE)
endfunction()

function(_parse_warning_config_file CONFIG_FILE)
    file(READ ${CONFIG_FILE} CONFIG_STRING)

    string(JSON VERSION GET ${CONFIG_STRING} version)
    message(DEBUG "Version: ${VERSION}")

    set(PARSE_COMMAND "_parse_warning_config_version_${VERSION}")
    if(NOT COMMAND ${PARSE_COMMAND})
        message(FATAL_ERROR "Version ${VERSION} for warning config file is not supported.")
    endif()
    cmake_language(CALL "_parse_warning_config_version_${VERSION}" "${CONFIG_STRING}")

    set(WARNINGS ${WARNINGS} PARENT_SCOPE)
endfunction()

function(cforge_target_add_warnings TARGET_NAME)
    cmake_parse_arguments("ARG" "WARNING_AS_ERROR" "CONFIG_FILE" "" ${ARGN})

    if(NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "Target ${TARGET_NAME} is not defined.")
    endif()

    if(ARG_WARNING_AS_ERROR)
        message(WARNING "`Warning as error` is not implemented for now and will be available with CMake 3.24+ only.")
    endif()

    _use_default_warning_config_file_if_arg_not_set(ARG_CONFIG_FILE)

    message(CHECK_START "Parsing warning config from file ${ARG_CONFIG_FILE}")
    list(APPEND CMAKE_MESSAGE_INDENT "  ")

    _parse_warning_config_file(${ARG_CONFIG_FILE})

    list(POP_BACK CMAKE_MESSAGE_INDENT)

    # All errors during parsing are fatal for now, so if we end up here everything is OK
    # There are also some warnings but they should not trigger a parsing failure at this point
    message(CHECK_PASS "done")

    # Force a reconfiguration of the build system if the JSON config file changes
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${ARG_CONFIG_FILE})

    message(DEBUG "Warnings: ${WARNINGS}")

    get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)
    if(${TARGET_TYPE} STREQUAL INTERFACE_LIBRARY)
        set(COMPILE_OPTIONS_SCOPE INTERFACE)
    else()
        # Using `PRIVATE` usage requirement to avoid transitive propagation
        # TODO Is this the best option here? Maybe the scope should be selected by the user
        set(COMPILE_OPTIONS_SCOPE PRIVATE)
    endif()
    target_compile_options(${TARGET_NAME} ${COMPILE_OPTIONS_SCOPE} ${WARNINGS})
endfunction()

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

function(cforge_target_add_warnings TARGET_NAME)
    cmake_parse_arguments("ARG" "WARNING_AS_ERROR" "CONFIG_FILE" "" ${ARGN})

    _use_default_warning_config_file_if_arg_not_set(ARG_CONFIG_FILE)

    message(CHECK_START "Parsing warning config from file ${ARG_CONFIG_FILE}")
    file(READ ${ARG_CONFIG_FILE} CONFIG_STRING)
    list(APPEND CMAKE_MESSAGE_INDENT "  ")

    string(JSON VERSION GET ${CONFIG_STRING} version)
    message(STATUS "Version: ${VERSION}")

    string(JSON PROFILE_COUNT LENGTH ${CONFIG_STRING} profiles)
    message(STATUS "Profile count: ${PROFILE_COUNT}")

    math(EXPR PROFILE_LAST "${PROFILE_COUNT} - 1")
    foreach(IDX RANGE ${PROFILE_LAST})
        message(STATUS "Profile #${IDX}:")
        list(APPEND CMAKE_MESSAGE_INDENT "  ")

            string(JSON COMPILER_ID GET ${CONFIG_STRING} profiles ${IDX} compiler_id)
            message(STATUS "Compiler ID: ${COMPILER_ID}")

        list(POP_BACK CMAKE_MESSAGE_INDENT)
    endforeach()

    list(POP_BACK CMAKE_MESSAGE_INDENT)
    if(ERROR_CODE)
        message(CHECK_FAIL "failed: ${ERROR_MESSAGE}")
    else()
        message(CHECK_PASS "done")
    endif()

endfunction()

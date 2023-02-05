# Requires CMAKE_CURRENT_FUNCTION_LIST_DIR
cmake_minimum_required(VERSION 3.17)

include_guard(GLOBAL)

#[=================================================================================================[.rst:
CForgeTargetAddWarnings
-----------------------

Add some warnings from a config file to a CMake target.

.. cmake:command:: cforge_target_add_warnings

  .. code-block:: cmake

    cforge_target_add_warnings(<target-name>
        [CONFIG_FILE <config-file>]
        [WARNING_AS_ERROR]
    )

If the ``CONFIG_FILE`` argument is not specified, the default config file
cmake/Modules/CForgeTargetAddWarnings/default-warnings.cmake will be used. This default config file
provides a reasonable set of warnings for GCC, Clang and MSVC that may be enabled in all projects.

The ``WARNING_AS_ERROR`` optional argument turns warnings into errors.
TODO This is not implemented for now. Using it will cause a configuration warning.
It may be implemented using COMPILE_WARNING_AS_ERROR target property, requiring CMake 3.24+.
#]=================================================================================================]

function(_use_default_warning_config_file_if_arg_not_set CONFIG_FILE)
    if(NOT ${CONFIG_FILE})
        set(USE_DEFAULT_CONFIG ON)
    elseif(NOT EXISTS ${${CONFIG_FILE}})
        message(WARNING "${${CONFIG_FILE}} does not exist. Using default config file.")
        set(USE_DEFAULT_CONFIG ON)
    endif()
    if(USE_DEFAULT_CONFIG)
        set(${CONFIG_FILE} ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeTargetAddWarnings/default-warnings.cmake PARENT_SCOPE)
    endif()
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

    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/CForgeTargetAddWarnings/CForgeDefineWarningProfile.cmake)
    include(${ARG_CONFIG_FILE})

    list(POP_BACK CMAKE_MESSAGE_INDENT)

    # All errors during parsing are fatal, so if we end up here everything is OK
    # There are also some warnings but they should not trigger a parsing failure at this point
    message(CHECK_PASS "done")

    message(NOTICE "Warnings: ${CFORGE_WARNINGS_ENABLED}")

    get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)
    if(${TARGET_TYPE} STREQUAL INTERFACE_LIBRARY)
        set(COMPILE_OPTIONS_SCOPE INTERFACE)
    else()
        # Using `PRIVATE` usage requirement to avoid transitive propagation
        # TODO Is this the best option here? Maybe the scope should be selected by the user
        set(COMPILE_OPTIONS_SCOPE PRIVATE)
    endif()
    target_compile_options(${TARGET_NAME} ${COMPILE_OPTIONS_SCOPE} ${CFORGE_WARNINGS_ENABLED})
endfunction()

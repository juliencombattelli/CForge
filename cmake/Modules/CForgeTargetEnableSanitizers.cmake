#[=================================================================================================[.rst:
CForgeTargetEnableSanitizers
----------------------------

Generate some options the user can toggle to enable sanitized build to a
specific target.

.. cmake:command:: cforge_target_enable_sanitizers

  .. code-block:: cmake

    cforge_target_enable_sanitizers(<target-name>)

This command generates one option per supported sanitizer for the given target.
By default, no sanitizer is enabled (all generated options are set to FALSE).

The options have the following naming:
``${CFORGE_PROJECT_PREFIX}_SANITIZE_<target-name>_<sanitizer-name>``.


  **Known limitations**

* Sanitizers are currently only supported with GCC and Clang.
* Supported sanitizers are ``address``, ``memory``, ``undefined``, ``thread``.
* No check is performed to ensure a given sanitizer is supported by the current
  toolchain, or compatible with the other sanitizers enabled (could be done with
  ``try_compile()`` though).

#]=================================================================================================]

cmake_minimum_required(VERSION 3.13) # TODO verify

include_guard(GLOBAL)

include(CForgeProjectInfo)

function(cforge_target_enable_sanitizers TARGET_NAME)

    if (NOT TARGET ${TARGET_NAME})
        message(FATAL_ERROR "${TARGET_NAME} is not a valid target")
    endif()

    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(SUPPORTED_SANITIZERS "address" "memory" "undefined" "thread")
    else()
        set(SUPPORTED_SANITIZERS "")
        message(VERBOSE "Sanitizers not supported for compiler of type ${CMAKE_CXX_COMPILER_ID}")
        return()
    endif()

    set(SANITIZERS "")

    foreach(sanitizer IN LISTS SUPPORTED_SANITIZERS)
        option(${CFORGE_PROJECT_PREFIX}_SANITIZE_${TARGET_NAME}_${sanitizer} "Enable sanitizer '${sanitizer}' for target ${TARGET_NAME}" OFF)
        if (${CFORGE_PROJECT_PREFIX}_SANITIZE_${TARGET_NAME}_${sanitizer})
            list(APPEND SANITIZERS "${sanitizer}")
        endif()
    endforeach()

    list(JOIN SANITIZERS "," LIST_OF_SANITIZERS)

    if(LIST_OF_SANITIZERS)
        if(NOT "${LIST_OF_SANITIZERS}" STREQUAL "")
            get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)
            if(${TARGET_TYPE} STREQUAL INTERFACE_LIBRARY)
                set(COMPILE_OPTIONS_SCOPE INTERFACE)
            else()
                # Using PUBLIC usage requirement to avoid ABI issue when
                # building a static library with sanitizers but not the main
                # executable
                set(COMPILE_OPTIONS_SCOPE PUBLIC)
            endif()
            target_compile_options(${TARGET_NAME} ${COMPILE_OPTIONS_SCOPE} -fsanitize=${LIST_OF_SANITIZERS})
            target_link_options(${TARGET_NAME} ${COMPILE_OPTIONS_SCOPE} -fsanitize=${LIST_OF_SANITIZERS})
        endif()
    endif()

endfunction()

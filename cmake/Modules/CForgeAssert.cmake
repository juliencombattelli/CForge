#[=======================================================================[.rst:
CForgeAssert
------------

This module provides functions for working with assertions.

#]=======================================================================]

include_guard(GLOBAL)

#[=======================================================================[.rst:
.. cmake:command:: cforge_assert

  Ensure that an expression evaluates to true. If it evaluates to false, a fatal
  error is emitted with a customizable message.

  .. code-block:: cmake

    cforge_assert(
        CONDITION <expr>
        [MESSAGE <message>]
    )

The expression passed to the ``CONDITION`` argument is evaluated using the
same logic as the :cmake:command:`if()` CMake command.

In case of assertion failure, a fatal error is generated with the message
``"Assertion failed!"``. If the ``MESSAGE`` argument is provided, it is appended
to the message of the fatal error.

  **Usage example**

  .. code-block:: cmake

    cforge_assert(CONDITION CMAKE_COMMAND AND CMAKE_VERSION MESSAGE "Ouch")

  Assert that both variables ``CMAKE_COMMAND`` and ``CMAKE_VERSION`` are defined.
  Print "Ouch" in case of failure.

  .. code-block:: cmake

    cforge_assert(CONDITION VAR STREQUAL "value")

  Assert that the variable ``VAR`` is equal to the string ``"value"``.

  .. code-block:: cmake

    cforge_assert(CONDITION INDEX LESS 100)

  Assert that the variable ``INDEX`` is less than ``100``.

#]=======================================================================]

function(cforge_assert)
    cmake_parse_arguments("ARG" "" "" "CONDITION;MESSAGE" ${ARGN})
    if(NOT ARG_CONDITION)
        message(FATAL_ERROR "CONDITION argument is required")
    endif()
    if(NOT (${ARG_CONDITION}))
        set(MESSAGE "Assertion failed!")
        if(ARG_MESSAGE)
            string(APPEND MESSAGE " " ${ARG_MESSAGE})
        endif()
        message(FATAL_ERROR "${MESSAGE}")
    endif()
endfunction()

#[=================================================================================================[.rst:
CForgeForceColoredOutput
------------------------

Force some compilers to always produce ANSI-colored output.

This module creates an option ``CFORGE_FORCE_COLORED_OUTPUT`` enabled by default.
It can be turned off when colors are not desired.

The supported compilers are GCC and Clang.

This is particularly useful when building with Ninja in combination of GCC or Clang,
as ANSI colors are disabled by default in this case.

Credits
^^^^^^^

This module is heavily inspired on the following Medium post written by Austin Lasher:
https://medium.com/@alasher/colored-c-compiler-output-with-ninja-clang-gcc-10bfe7f2b949

#]=================================================================================================]

option(CFORGE_FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." TRUE)

if(${CFORGE_FORCE_COLORED_OUTPUT})
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        add_compile_options(-fdiagnostics-color=always)
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        add_compile_options(-fcolor-diagnostics)
    else()
        # Intentionnally do not emit a warning if CFORGE_FORCE_COLORED_OUTPUT was requested but the
        # current compiler is not supported as it would be needlessly too noisy for the user.
    endif()
endif()

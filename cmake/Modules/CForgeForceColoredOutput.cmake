#[=================================================================================================[.rst:
CForgeForceColoredOutput
------------------------

Force some compilers to always produce ANSI-colored output.

This module creates an option ``${CFORGE_PROJECT_PREFIX}_FORCE_COLORED_OUTPUT``
enabled by default. It can be turned off when colors are not desired.

The supported compilers are GCC and Clang.

This is particularly useful when building with Ninja in combination of GCC or Clang,
as ANSI colors are disabled by default in this case.

Credits
^^^^^^^

This module is heavily inspired on the following Medium post written by Austin Lasher:
https://medium.com/@alasher/colored-c-compiler-output-with-ninja-clang-gcc-10bfe7f2b949

#]=================================================================================================]

include_guard(GLOBAL)

include(CForgeProjectInfo)

option(${CFORGE_PROJECT_PREFIX}_FORCE_COLORED_OUTPUT "Always produce ANSI-colored output (GNU/Clang only)." TRUE)

if(${${CFORGE_PROJECT_PREFIX}_FORCE_COLORED_OUTPUT})
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        # For GCC, colors can also be forced using the GCC_COLORS environment
        # variable as explained here:
        # https://gcc.gnu.org/onlinedocs/gcc/Diagnostic-Message-Formatting-Options.html#index-fdiagnostics-color
        add_compile_options(-fdiagnostics-color=always)
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        add_compile_options(-fcolor-diagnostics)
        if(CMAKE_HOST_WIN32)
            # Force to use ANSI color codes on Windows
            add_compile_options(-fansi-escape-codes)
        endif()
    else()
        # Intentionnally do not emit a warning if ${CFORGE_PROJECT_PREFIX}_FORCE_COLORED_OUTPUT
        # was requested but the current compiler is not supported as it would be
        # needlessly noisy for the user.
    endif()
endif()

#[=================================================================================================[.rst:
FindLCOV
--------

Finds the coverage analysis tools from LCOV project.

.. note:: LCOV consists of several Perl scripts. As such, a Perl interpreter must also be available
  and is searched for using :cmake:module:`FindPerl` module from the official CMake distribution.

Hints
^^^^^

This module reads hints about search locations from variables:

``LCOV_ROOT``
Preferred installation prefix.

Users may set these hints as normal CMake variables, cache entries or environment variables.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``LCOV::LCOV``
  The lcov coverage data collector executable.

``LCOV::GenHTML``
  The genhtml coverage report generator executable.

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``LCOV_FOUND``
  True if the system has LCOV installed.
``LCOV_VERSION``
  The version of LCOV which was found.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``LCOV_EXECUTABLE``
  The full path to lcov executable (including Perl interpreter).
``GenHTML_EXECUTABLE``
  The full path to genhtml executable (including Perl interpreter).

Design note
^^^^^^^^^^^

Each script from LCOV project may depend on each other.
From one version to another, these dependencies may change, and scripts may be added or removed.
Consequenlty, to have a robust and maintanable find module, only the scripts that are actually
useful from a user perspective and independant from each others will be searched for.
Those scripts are lcov and genhtml.
They must be both sucessfully located to consider that LCOV was found. In other words, they are
not treated as components.

#]=================================================================================================]

find_package(Perl)

find_program(LCOV_EXECUTABLE
    NAMES lcov
    HINTS $ENV{LCOV_HOME}/bin # From chocolatey installation
)

find_program(GenHTML_EXECUTABLE
    NAMES genhtml
    HINTS $ENV{LCOV_HOME}/bin # From chocolatey installation
)

if(PERL_EXECUTABLE AND LCOV_EXECUTABLE)
    execute_process(
        COMMAND ${PERL_EXECUTABLE} ${LCOV_EXECUTABLE} --version
        OUTPUT_VARIABLE LCOV_VERSION
    )
    string(REGEX REPLACE "^lcov: LCOV version [v]?(.*)" "\\1" LCOV_VERSION "${LCOV_VERSION}")
    string(STRIP "${LCOV_VERSION}" LCOV_VERSION)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LCOV
    REQUIRED_VARS LCOV_EXECUTABLE GenHTML_EXECUTABLE PERL_FOUND
    VERSION_VAR LCOV_VERSION
)

if(LCOV_FOUND)
    # Preppend Perl interpreter before executable scripts
    # May allow to choose the version of Perl used (depending on how FindPerl.cmake is designed)
    set(LCOV_EXECUTABLE ${PERL_EXECUTABLE} ${LCOV_EXECUTABLE})
    set(GenHTML_EXECUTABLE ${PERL_EXECUTABLE} ${GenHTML_EXECUTABLE})

    mark_as_advanced(LCOV_EXECUTABLE GenHTML_EXECUTABLE)

    if(NOT TARGET LCOV::LCOV)
        add_executable(LCOV::LCOV IMPORTED)
        set_property(TARGET LCOV::LCOV PROPERTY IMPORTED_LOCATION ${LCOV_EXECUTABLE})
    endif()
    if(NOT TARGET LCOV::GenHTML)
        add_executable(LCOV::GenHTML IMPORTED)
        set_property(TARGET LCOV::GenHTML PROPERTY IMPORTED_LOCATION ${GenHTML_EXECUTABLE})
    endif()
endif()

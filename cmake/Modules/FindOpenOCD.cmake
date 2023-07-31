#[=======================================================================[.rst:
FindOpenOCD
-----------

Find the Open On-Chip Debugger.

Hints
^^^^^

This module reads hints about search locations from variables:

``OpenOCD_ROOT``
  Preferred installation prefix.

Users may set these hints as normal CMake variables, cache entries or environment variables.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``OpenOCD::OpenOCD``
  The Open On-Chip Debugger executable.

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``OpenOCD_FOUND``
  True if the system has OpenOCD installed.
``OpenOCD_VERSION``
  The version of OpenOCD which was found (eg. 2.5.7).
``OpenOCD_VERSION_MAJOR``
  The major version number of OpenOCD which was found (eg. 2).
``OpenOCD_VERSION_MINOR``
  The minor version number of OpenOCD which was found (eg. 5).
``OpenOCD_VERSION_PATCH``
  The patch version number of OpenOCD which was found (eg. 7).

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``OpenOCD_EXECUTABLE``
  The full path to the OpenOCD executable.

#]=======================================================================]

# First search the PATH and specific locations.
find_program(OpenOCD_EXECUTABLE
    NAMES openocd.exe openocd
    DOC "Path to the OpenOCD executable"
)

unset(_openocd_names)
unset(_openocd_paths)

if(OpenOCD_EXECUTABLE)
    # Determine OpenOCD version string
    execute_process(
        COMMAND "${OpenOCD_EXECUTABLE}" --version
        ERROR_VARIABLE _openocd_version # OpenOCD outputs version into stderr
        RESULT_VARIABLE _openocd_version_result
    )
    if(NOT _openocd_version_result)
        string(REGEX MATCH "Open On-Chip Debugger ([0-9]+.[0-9]+.[0-9]+)" _openocd_version_match "${_openocd_version}")
        set(OpenOCD_VERSION ${CMAKE_MATCH_1})
        string(REPLACE "." ";" _openocd_version_list "${OpenOCD_VERSION}")
        list(GET _openocd_version_list 0 OpenOCD_VERSION_MAJOR)
        list(GET _openocd_version_list 1 OpenOCD_VERSION_MINOR)
        list(GET _openocd_version_list 2 OpenOCD_VERSION_PATCH)
        unset(_openocd_version_match)
        unset(_openocd_version_list)
    endif()
    unset(_openocd_version)
    unset(_openocd_version_result)
endif()

# Process find_package arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OpenOCD
    REQUIRED_VARS
        OpenOCD_EXECUTABLE
    VERSION_VAR
        OpenOCD_VERSION
)

if(OpenOCD_FOUND)
    mark_as_advanced(OpenOCD_EXECUTABLE)
    # Export OpenOCD target
    if(NOT TARGET OpenOCD::OpenOCD)
        add_executable(OpenOCD::OpenOCD IMPORTED)
        set_property(TARGET OpenOCD::OpenOCD PROPERTY IMPORTED_LOCATION "${OpenOCD_EXECUTABLE}")
    endif()
endif()

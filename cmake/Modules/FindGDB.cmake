#[=======================================================================[.rst:
FindGDB
-------

Find the GNU Debugger.

Hints
^^^^^

This module reads hints about search locations from variables:

``GDB_ROOT``
  Preferred installation prefix.

Users may set these hints as normal CMake variables, cache entries or environment variables.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``GDB::GDB``
  The GNU Debugger executable.

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``GDB_FOUND``
  True if the system has GDB installed.
``GDB_VERSION``
  The version of GDB which was found (eg. 2.5).
``GDB_VERSION_MAJOR``
  GDB major version found (eg. 2).
``GDB_VERSION_MINOR``
  GDB minor version found (eg. 5).

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``GDB_EXECUTABLE``
  The full path to the GDB executable.

Components
^^^^^^^^^^

The module accepts architecture support query using COMPONENTS.
For example, support for armv7e-m and i386 architectures can be check as follow:

.. code-block:: cmake

  find_package(GDB COMPONENTS armv7e-m i386)
  if(GDB_FOUND)
    message("GDB found: ${GDB_EXECUTABLE}")
  endif()

#]=======================================================================]

set(_gdb_names "")

# If the current toolchain defines a compiler target prefix, use it
if(DEFINED CMAKE_C_COMPILER_TARGET)
    list(APPEND _gdb_names ${CMAKE_C_COMPILER_TARGET}-gdb)
endif()
if(DEFINED CMAKE_CXX_COMPILER_TARGET)
    list(APPEND _gdb_names ${CMAKE_CXX_COMPILER_TARGET}-gdb)
endif()

list(APPEND _gdb_names gdb-multiarch gdb)

# If running on Windows, search for *.exe as well
if(CMAKE_HOST_WIN32)
    list(APPEND _gdb_names ${_gdb_names}.exe)
endif()

# Remove potential duplicates
list(REMOVE_DUPLICATES _gdb_names)

# Search the PATH and specific locations
find_program(GDB_EXECUTABLE
    NAMES ${_gdb_names}
    DOC "Path to the GDB executable"
)

unset(_gdb_names)

if(GDB_EXECUTABLE)
    # Get GDB version message
    execute_process(
        COMMAND ${GDB_EXECUTABLE} --version
        OUTPUT_VARIABLE _gdb_version
        RESULT_VARIABLE _gdb_version_result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # If GDB version command returned successfully
    if(NOT _gdb_version_result)
        # Extract version string
        string(REGEX REPLACE "GNU gdb \\([^)]*\\) [^0-9]*([0-9]+[0-9.]*).*" "\\1" GDB_VERSION "${_gdb_version}")
        string(REPLACE "." ";" _gdb_version_list "${GDB_VERSION}")
        list(GET _gdb_version_list 0 GDB_VERSION_MAJOR)
        list(GET _gdb_version_list 1 GDB_VERSION_MINOR)
    endif()

    unset(_gdb_version)
    unset(_gdb_version_list)

    foreach(_arch IN LISTS GDB_FIND_COMPONENTS)
        # Check if this architecture is supported
        execute_process(
            COMMAND ${GDB_EXECUTABLE} --batch -ex "set architecture ${_arch}"
            RESULT_VARIABLE _check_result
            OUTPUT_QUIET ERROR_QUIET
        )
        # If arch is supported, set the corresponding component variable
        if(NOT _check_result EQUAL 1)
            set(GDB_${_arch}_FOUND TRUE)
        endif()
        unset(_check_result)
    endforeach()
endif()

# Process find_package arguments
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GDB
    REQUIRED_VARS
        GDB_EXECUTABLE
    VERSION_VAR
        GDB_VERSION
    HANDLE_COMPONENTS
)

if(GDB_FOUND)
    mark_as_advanced(GDB_EXECUTABLE)
    # Export GDB executable target
    if(GDB_IS_VALID AND NOT TARGET GDB::GDB)
        add_executable(GDB::GDB IMPORTED)
        set_property(TARGET GDB::GDB PROPERTY IMPORTED_LOCATION "${GDB_EXECUTABLE}")
    endif()
endif()

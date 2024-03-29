#[=================================================================================================[.rst:
FindSphinx
----------

Find the Sphinx documentation generator.

Hints
^^^^^

This module reads hints about search locations from variables:

``Sphinx_ROOT``
  Preferred installation prefix.

Users may set these hints as normal CMake variables, cache entries or environment variables.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``Sphinx::Sphinx``
  The sphinx executable.

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``SphinxFOUND``
  True if the system has Sphinx installed.
``Sphinx_VERSION``
  The version of Sphinx which was found.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``Sphinx_EXECUTABLE``
  The full path to sphinx-build executable.

#]=================================================================================================]

find_package(Python3 COMPONENTS Interpreter)
if(Python3_Interpreter_FOUND)
    # We are likely to find Sphinx near the Python interpreter
    get_filename_component(_PYTHON_DIR "${Python3_EXECUTABLE}" DIRECTORY)
    set(_PYTHON_PATHS
        "${_PYTHON_DIR}"
        "${_PYTHON_DIR}/bin"
        "${_PYTHON_DIR}/Scripts"
    )
endif()

find_program(Sphinx_EXECUTABLE
    NAMES sphinx-build sphinx-build.exe
    HINTS ${_PYTHON_PATHS}
    DOC "Path to sphinx-build executable"
)

if(Sphinx_EXECUTABLE)
    execute_process(
        COMMAND ${Sphinx_EXECUTABLE} --version
        OUTPUT_VARIABLE Sphinx_VERSION
    )
    string(REGEX REPLACE "^sphinx-build (.*)" "\\1" Sphinx_VERSION "${Sphinx_VERSION}")
    string(STRIP "${Sphinx_VERSION}" Sphinx_VERSION)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Sphinx
    REQUIRED_VARS
        Sphinx_EXECUTABLE
    VERSION_VAR
        Sphinx_VERSION
)

if(Sphinx_FOUND)
    mark_as_advanced(Sphinx_EXECUTABLE)
    if(NOT TARGET Sphinx::Sphinx)
        add_executable(Sphinx::Sphinx IMPORTED)
        set_property(TARGET Sphinx::Sphinx PROPERTY IMPORTED_LOCATION ${Sphinx_EXECUTABLE})
    endif()
endif()

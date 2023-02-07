#[=======================================================================[.rst:
FindSphinx
----------

Find the Sphinx documentation generator.

#]=======================================================================]

# We are likely to find Sphinx near the Python interpreter
# TODO use FindPython instead
find_package(PythonInterp)
if(PYTHONINTERP_FOUND)
    get_filename_component(_PYTHON_DIR "${PYTHON_EXECUTABLE}" DIRECTORY)
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

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Sphinx DEFAULT_MSG Sphinx_EXECUTABLE)

if(Sphinx_FOUND)
    mark_as_advanced(Sphinx_EXECUTABLE)
    if(NOT TARGET Sphinx::Sphinx)
        add_executable(Sphinx::Sphinx IMPORTED)
        set_property(TARGET Sphinx::Sphinx PROPERTY IMPORTED_LOCATION ${Sphinx_EXECUTABLE})
    endif()
endif()

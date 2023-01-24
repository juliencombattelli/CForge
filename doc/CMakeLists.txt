find_package(Sphinx REQUIRED)

get_filename_component(CONF_FILE "conf.py" ABSOLUTE)
get_filename_component(SOURCE_DIR "${CONF_FILE}" DIRECTORY)
set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(CACHE_DIR "${OUT_DIR}.cache")

string(TIMESTAMP CURRENT_YEAR "%Y" UTC)

configure_file("${CONF_FILE}" "${CACHE_DIR}/conf.py" @ONLY)

option(CFORGE_DOCUMENTATION_VERIFY_CERTIFICATE "Control certificate check when downloading CMake inventory file" ON)
if(NOT CFORGE_DOCUMENTATION_VERIFY_CERTIFICATE)
    set(CERTIFICATE_CHECK_OPTION "--no-check-certificate")
endif()

# Fetch and patch the Sphinx inventory file from cmake.org to have working links to CMake documentation
# The generated target will always be considered out-of-date since the upstream CMake inventory can change
add_custom_target(doc-patch-cmake-inventory
    COMMAND "${PYTHON_EXECUTABLE}" -B "${SOURCE_DIR}/patch-cmake-objects-inv.py" ${CERTIFICATE_CHECK_OPTION}
        "${CACHE_DIR}/cmake-objects.patched.inv"
    COMMENT "Patching Sphinx inventory file from cmake.org"
    DEPENDS "${SOURCE_DIR}/patch-cmake-objects-inv.py"
    VERBATIM
)

# Run Sphinx to generate the html documentation
# The generated target will always be considered out-of-date as sphinx already handled dependencies at file-level
add_custom_target(doc
    COMMAND "${SPHINX_EXECUTABLE}" -q -b html -c "${CACHE_DIR}" "${SOURCE_DIR}" "${OUT_DIR}"
    COMMENT "Generating html documentation"
    DEPENDS "${CACHE_DIR}/conf.py"
    VERBATIM
)
add_dependencies(doc doc-patch-cmake-inventory)

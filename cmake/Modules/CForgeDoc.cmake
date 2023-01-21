find_package(Sphinx REQUIRED)

function(cforge_add_documentation TARGET_NAME)
    cmake_parse_arguments(${TARGET_NAME} "" "CONF_FILE" "" ${ARGN})

    get_filename_component(CONF_FILE "${${TARGET_NAME}_CONF_FILE}" ABSOLUTE)
    get_filename_component(CONF_FILE_NAME "${CONF_FILE}" NAME)
    get_filename_component(SOURCE_DIR "${CONF_FILE}" DIRECTORY)
    set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}")
    set(CACHE_DIR "${OUT_DIR}.cache")

    string(TIMESTAMP CURRENT_YEAR "%Y" UTC)

    configure_file("${CONF_FILE}" "${CACHE_DIR}/${CONF_FILE_NAME}" @ONLY)

    # Fetch and patch the Sphinx inventory file from cmake.org to have working links to CMake documentation
    # The generated target will always be considered out-of-date since the upstream CMake inventory can change
    add_custom_target(${TARGET_NAME}-patch-cmake-inventory
        COMMAND "${PYTHON_EXECUTABLE}" "${SOURCE_DIR}/patch-cmake-objects-inv.py"
            "${CACHE_DIR}/cmake-objects.inv" "${CACHE_DIR}/cmake-objects.patched.inv"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Patching Sphinx inventory file from cmake.org"
        DEPENDS "${SOURCE_DIR}/patch-cmake-objects-inv.py"
        VERBATIM
    )

    # Run Sphinx to generate the html documentation
    # The generated target will always be considered out-of-date as sphinx already handled dependencies at file-level
    add_custom_target(${TARGET_NAME}
        COMMAND "${SPHINX_EXECUTABLE}" -q -b html -c "${CACHE_DIR}" "${SOURCE_DIR}" "${OUT_DIR}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Generating html documentation"
        DEPENDS "${CACHE_DIR}/${CONF_FILE_NAME}"
        VERBATIM
    )
    add_dependencies(${TARGET_NAME} ${TARGET_NAME}-patch-cmake-inventory)
endfunction()

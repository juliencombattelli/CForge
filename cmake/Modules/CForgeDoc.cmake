find_package(Sphinx REQUIRED)

function(cforge_add_documentation TARGET_NAME)
    cmake_parse_arguments(${TARGET_NAME} "" "CONF_FILE" "" ${ARGN})

    get_filename_component(CONF_FILE "${${TARGET_NAME}_CONF_FILE}" ABSOLUTE)
    get_filename_component(CONF_FILE_NAME "${CONF_FILE}" NAME)
    get_filename_component(SOURCE_DIR "${CONF_FILE}" DIRECTORY)
    set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}")

    string(TIMESTAMP CURRENT_YEAR "%Y" UTC)

    configure_file("${CONF_FILE}" "${OUT_DIR}.cache/${CONF_FILE_NAME}" @ONLY)
    file(MAKE_DIRECTORY "${OUT_DIR}.cache/_static/") # Empty _static folder next to conf file, needed by Sphinx for some reason

    # The generated target will always be considered out-of-date since sphinx already handled
    # dependencies at file-level
    add_custom_target(${TARGET_NAME}
        COMMAND "${SPHINX_EXECUTABLE}" -q -b html -c "${OUT_DIR}.cache" "${SOURCE_DIR}" "${OUT_DIR}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Generating documentation"
        DEPENDS "${OUT_DIR}.cache/${CONF_FILE_NAME}"
        VERBATIM
    )
endfunction()

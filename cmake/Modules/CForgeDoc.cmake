find_package(Sphinx REQUIRED)

function(cforge_add_documentation TARGET_NAME)
    cmake_parse_arguments(${TARGET_NAME} "" "CONF_FILE" "" ${ARGN})

    get_filename_component(CONF_FILE "${${TARGET_NAME}_CONF_FILE}" ABSOLUTE)
    get_filename_component(CONF_DIR "${CONF_FILE}" DIRECTORY)
    set(OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}")

    string(TIMESTAMP CURRENT_YEAR "%Y" UTC)

    # The generated target will always be considered out-of-date since sphinx already handled
    # dependencies at file-level
    add_custom_target(${TARGET_NAME}
        COMMAND "${SPHINX_EXECUTABLE}" -q -b html "${CONF_DIR}" "${OUT_DIR}"
            "-Dproject=${PROJECT_NAME}"
            "-Dcopyright=${CURRENT_YEAR}, ${PROJECT_AUTHOR}"
            "-Dauthor=${PROJECT_AUTHOR}"
            "-Dversion=${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}"
            "-Drelease=${PROJECT_VERSION}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Generating documentation"
        DEPENDS "${CONF_FILE}"
        VERBATIM
    )
endfunction()

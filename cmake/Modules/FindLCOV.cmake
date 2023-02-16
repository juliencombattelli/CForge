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

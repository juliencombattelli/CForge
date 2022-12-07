include(${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake)

# Prepare expected warnings for each profiles
# Profiles to be tested are stored in the list TESTED_PROFILES
# Expected warnings for a specific profile are stored in the list <profile>_EXPECTED_WARNINGS
list(APPEND WARNING_ID_SUFFIX _ A B C)
foreach(INHERIT_COUNT RANGE 0 3)
    if(INHERIT_COUNT GREATER 0)
        foreach(INHERIT_NB RANGE 1 ${INHERIT_COUNT})
            list(GET WARNING_ID_SUFFIX ${INHERIT_NB} SUFFIX)
            list(APPEND EXPECTED_INHERITED_WARNINGS "Common${INHERIT_COUNT}${SUFFIX}")
        endforeach()
    endif()
    foreach(WARNING_COUNT RANGE 0 3)
        set(CURRENT_PROFILE "Profile${WARNING_COUNT}W${INHERIT_COUNT}I")
        list(APPEND TESTED_PROFILES ${CURRENT_PROFILE})
        unset(EXPECTED_WARNINGS)
        list(APPEND EXPECTED_WARNINGS ${EXPECTED_INHERITED_WARNINGS})
        if(WARNING_COUNT GREATER 0)
            foreach(WARNING_NB RANGE 1 ${WARNING_COUNT})
                list(GET WARNING_ID_SUFFIX ${WARNING_NB} SUFFIX)
                list(APPEND EXPECTED_WARNINGS "Warning${WARNING_COUNT}${SUFFIX}")
            endforeach()
        endif()
        set(${CURRENT_PROFILE}_EXPECTED_WARNINGS ${EXPECTED_WARNINGS})
    endforeach()
endforeach()

# Test each profiles from valid-profiles.json and ensure the correct warnings are retrieved
foreach(PROFILE IN LISTS TESTED_PROFILES)
    set(EXPECTED_WARNINGS ${${PROFILE}_EXPECTED_WARNINGS})

    message(CHECK_START "Testing profile ${PROFILE}")
    list(APPEND CMAKE_MESSAGE_INDENT "  ")

    message(STATUS "Expecting warnings: \"${EXPECTED_WARNINGS}\"")

    # Run cforge_target_add_warnings with the tested profile
    set(CMAKE_CXX_COMPILER_ID ${PROFILE})
    set(CURRENT_TARGET TestTargetAddWarnings${PROFILE})
    add_library(${CURRENT_TARGET} INTERFACE)
    cforge_target_add_warnings(${CURRENT_TARGET} CONFIG_FILE "${CMAKE_CURRENT_LIST_DIR}/valid-profiles.json")
    get_target_property(COMPILE_OPTIONS ${CURRENT_TARGET} INTERFACE_COMPILE_OPTIONS)

    # Assert the retrieved warnings match the expected ones
    list(POP_BACK CMAKE_MESSAGE_INDENT)
    if(NOT COMPILE_OPTIONS)
        set(COMPILE_OPTIONS "")
    endif()
    # Use quoting since (COMPILE_OPTIONS STREQUAL EXPECTED_WARNINGS) evaluates to false if both are empty strings
    if("${COMPILE_OPTIONS}" STREQUAL "${EXPECTED_WARNINGS}")
        message(CHECK_PASS "passed")
    else()
        message(CHECK_FAIL "failed")
        message(SEND_ERROR "Not matching: \"${COMPILE_OPTIONS}\" != \"${EXPECTED_WARNINGS}\"")
    endif()
endforeach()

#[=================================================================================================[

cforge_define_warning_profile(
    NAME <profile-name>
    [COMPILER_ID <compiler-id>]
    [INHERIT PROFILES <profile-name>... [LOCATION <filepath>]] [...]
    [WARNINGS <warnings>...]
)

#]=================================================================================================]

include(CForgeAssert)

function(_cforge_process_warning_profile)
    cmake_parse_arguments("ARG" "" "LOCATION" "" ${ARGN})
    set(PROFILES ${ARG_UNPARSED_ARGUMENTS})
    unset(WARNING)
    if(ARG_LOCATION)
        include(${ARG_LOCATION})
    endif()
    foreach(PROFILE IN LISTS PROFILES)
        list(APPEND WARNING ${CFORGE_WARNINGS_PROFILE_${PROFILE}_WARNINGS})
    endforeach()
    set(WARNING "${WARNING}" PARENT_SCOPE)
endfunction()

function(cforge_define_warning_profile)
    cmake_parse_arguments("ARG" "" "NAME;COMPILER_ID" "INHERIT;WARNINGS" ${ARGN})

    if(ARG_INHERIT)
        set(INHERITED_PROFILES ${ARG_INHERIT})
        while(TRUE)
            # Ensure first element is PROFILES keyword argument
            list(GET INHERITED_PROFILES 0 FIRST_ELEMENT)
            cforge_assert(CONDITION FIRST_ELEMENT STREQUAL "PROFILES")
            # Remove first PROFILES keyword and find the next one
            list(POP_FRONT INHERITED_PROFILES)
            list(FIND INHERITED_PROFILES "PROFILES" NEXT_PROFILE_IDX)
            # Extract the current profile information
            list(SUBLIST INHERITED_PROFILES 0 ${NEXT_PROFILE_IDX} PROFILE)
            # Process current profile
            _cforge_process_warning_profile(${PROFILE})
            # Break loop if end of list is reached
            if(NEXT_PROFILE_IDX EQUAL -1)
                break()
            endif()
            # Remove the processed profile from the list
            list(SUBLIST INHERITED_PROFILES ${NEXT_PROFILE_IDX} -1 INHERITED_PROFILES)
        endwhile()
    endif()

    # Add warnings from inherited profiles
    list(APPEND CFORGE_WARNINGS_PROFILE_${ARG_NAME}_WARNINGS ${WARNING})
    # Add provided warnings
    list(APPEND CFORGE_WARNINGS_PROFILE_${ARG_NAME}_WARNINGS ${ARG_WARNINGS})

    # Add profile to known profiles list
    list(APPEND CFORGE_WARNINGS_PROFILES "${ARG_NAME}")

    # Export variables to parent scope
    set(CFORGE_WARNINGS_PROFILES "${CFORGE_WARNINGS_PROFILES}" PARENT_SCOPE)
    set(CFORGE_WARNINGS_PROFILE_${ARG_NAME}_WARNINGS "${CFORGE_WARNINGS_PROFILE_${ARG_NAME}_WARNINGS}" PARENT_SCOPE)

    if(ARG_COMPILER_ID)
        # If COMPILER_ID is provided, check if those warnings can be applied
        set(CFORGE_WARNINGS_PROFILE_${ARG_NAME}_COMPILER_ID "${ARG_COMPILER_ID}" PARENT_SCOPE)
        message(DEBUG "Compiler ID: ${ARG_COMPILER_ID}")
        if(NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES ${ARG_COMPILER_ID})
            message(DEBUG "Compiler ID: ${ARG_COMPILER_ID} - does not match")
        else()
            message(DEBUG "Compiler ID: ${ARG_COMPILER_ID} - matches")
            list(APPEND CFORGE_WARNINGS_ENABLED ${CFORGE_WARNINGS_PROFILE_${ARG_NAME}_WARNINGS})
        endif()
        # Export the enabled warning to parent scope
        set(CFORGE_WARNINGS_ENABLED "${CFORGE_WARNINGS_ENABLED}" PARENT_SCOPE)
    endif()
endfunction()

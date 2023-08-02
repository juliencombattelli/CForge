include_guard(GLOBAL)

function(cforge_assert)
    cmake_parse_arguments("ARG" "" "" "CONDITION;MESSAGE" ${ARGN})
    if(NOT ARG_CONDITION)
        message(FATAL_ERROR "CONDITION argument is required")
    endif()
    if(NOT (${ARG_CONDITION}))
        set(MESSAGE "Assertion failed!")
        if(ARG_MESSAGE)
            string(APPEND MESSAGE " " ${ARG_MESSAGE})
        endif()
        message(FATAL_ERROR "${MESSAGE}")
    endif()
endfunction()

# Matchers operating on function/macro individual argument
function(cforge_matcher_argument)
    cmake_parse_arguments("cforge_matcher_argument" # Intentionnally long prefix to avoid clashing with parent
        "have_value;have_no_value"
        "with_prefix"
        "argument"
        ${ARGN}
    )
    set(arguments ${cforge_matcher_argument_argument})
    set(prefix ${cforge_matcher_argument_with_prefix})
    set(have_value ${cforge_matcher_argument_have_value})
    set(have_no_value ${cforge_matcher_argument_have_no_value})

    if(have_value OR have_no_value)
        if(have_value AND have_no_value)
            message(FATAL_ERROR "Exaclty one of have_value and have_no_value must be provided.")
        endif()
        if(have_no_value)
            set(NEGATE NOT)
        endif()
        foreach(argument IN LISTS arguments)
            message("Checking if ${negate} (${argument} IN_LIST ${${prefix}_KEYWORDS_MISSING_VALUES})")
            if(${NEGATE} (${argument} IN_LIST ${prefix}_KEYWORDS_MISSING_VALUES))
                message(SEND_ERROR "Missing value for argument ${argument}")
                set(CFORGE_MATCHER_ERROR ON PARENT_SCOPE)
            endif()
        endforeach()
    endif()

    if(CFORGE_MATCHER_ERROR)
        message(FATAL_ERROR "Assertion failed")
    endif()
endfunction()

# Matchers operating on all function/macro arguments
function(cforge_matcher_arguments)
    cmake_parse_arguments("cforge_matcher_argument" # Intentionnally long prefix to avoid clashing with parent
        "arguments;have_unknown_argument;have_no_unknown_argument"
        "with_prefix"
        ""
        ${ARGN}
    )
    set(prefix ${cforge_matcher_argument_with_prefix})
    set(have_unknown_argument ${cforge_matcher_argument_have_unknown_argument})
    set(have_no_unknown_argument ${cforge_matcher_argument_have_no_unknown_argument})

    if(have_unknown_argument OR have_no_unknown_argument)
        if(have_unknown_argument AND have_no_unknown_argument)
            message(FATAL_ERROR "Exaclty one of have_unknown_argument and have_no_unknown_argument must be provided.")
        endif()
        if(have_unknown_argument)
            set(NEGATE NOT)
        endif()
        message("Checking if ${NEGATE} (${${prefix}_UNPARSED_ARGUMENTS})")
        if(${NEGATE} ${prefix}_UNPARSED_ARGUMENTS)
            message(SEND_ERROR "Unknown arguments ${${prefix}_UNPARSED_ARGUMENTS}")
            set(CFORGE_MATCHER_ERROR ON PARENT_SCOPE)
        endif()
    endif()

    if(CFORGE_MATCHER_ERROR)
        message(FATAL_ERROR "Assertion failed")
    endif()
endfunction()


# Matcher on strings
function(cforge_matcher_string)
    cmake_parse_arguments(""
        "is_empty;is_not_empty"
        ""
        "string"
        ${ARGN}
    )
    if(_is_empty OR _is_not_empty)
        if(_is_empty AND _is_not_empty)
            message(FATAL_ERROR "Exaclty one of is_empty and is_not_empty must be provided.")
        endif()
        foreach(string IN LISTS _string)
            if(NOT DEFINED ${string})
                message(SEND_ERROR "${string} is not defined")
                set(CFORGE_MATCHER_ERROR ON PARENT_SCOPE)
            elseif(_is_empty AND ${string})
                message(SEND_ERROR "${string} is not empty")
                set(CFORGE_MATCHER_ERROR ON PARENT_SCOPE)
            elseif(_is_not_empty AND NOT ${string})
                message(SEND_ERROR "${string} is empty")
                set(CFORGE_MATCHER_ERROR ON PARENT_SCOPE)
            endif()
        endforeach()
    endif()

    if(CFORGE_MATCHER_ERROR)
        message(FATAL_ERROR "Assertion failed")
    endif()
endfunction()

function(cforge_assert_that MAIN_MATCHER)
    set(MATCHER_FUNCTION cforge_matcher_${MAIN_MATCHER})
    if(COMMAND ${MATCHER_FUNCTION})
        cmake_language(CALL ${MATCHER_FUNCTION} ${ARGV})
    else()
        message(FATAL_ERROR "Matcher ${MAIN_MATCHER} is unknown. Please define cforge_matcher_${MAIN_MATCHER}.")
    endif()
endfunction()

# Example invocation:
# cforge_assert_that(argument ARG [ARG...] with_prefix PREFIX have_value)
# cforge_assert_that(argument ARG [ARG...] with_prefix PREFIX have_no_value)
# cforge_assert_that(arguments with_prefix PREFIX have_unknown_argument)
# cforge_assert_that(arguments with_prefix PREFIX have_no_unknown_argument)
# cforge_assert_that(string ARG [ARG...] is_empty)
# cforge_assert_that(string ARG [ARG...] is_not_empty)

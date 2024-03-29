# Block(PROPAGATE) from CMake 3.25
# Bug with CMake trace feature fixed in 3.24
# See https://gitlab.kitware.com/cmake/cmake/-/merge_requests/7118
cmake_minimum_required(VERSION 3.25)

include(CForgeJSON)

#[[
    Parse the source file FILE and get all executable lines and branches
    Ignore single line comments, bracket (multiline) comments, builtin commands closing
        blocks (eg. endif), and else command

    Store executable lines in the list _CFORGE_UNIT_COVERAGE_EXECUTABLE_LINES_FOR_${FILE}
    Store executable branches as a JSON object in _CFORGE_UNIT_COVERAGE_EXECUTABLE_BRANCHES_FOR_${FILE}
    Format of branch JSON object:
    {
        "filename": <string>,
        "blocks": [
            {
                "line": <int>,
                "branches": [
                    {
                        "type": "if" or "elseif" or "else",
                        "line": <int>,
                        "first_exec_line": <int>
                    },
                    ...
                ],
            },
            ...
        ]
    }
#]]
function(_cforge_unit_coverage_get_executable_lines FILE)
    list(APPEND _CFORGE_UNIT_COVERAGE_FILES "${FILE}")
    set(_CFORGE_UNIT_COVERAGE_FILES "${_CFORGE_UNIT_COVERAGE_FILES}" CACHE INTERNAL "" FORCE)

    set(BRACKET_OPEN_REGEX "\\[=*\\[")
    set(BRACKET_CLOSE_REGEX "\\]=*\\]")

    # Known limitation with bracket handling in CMake lists
    # https://gitlab.kitware.com/cmake/cmake/-/issues/19156
    # Replace square brackets with arbitrary tokens to avoid the issue above
    file(STRINGS "${FILE}" FILE_CONTENTS)
    string(REGEX REPLACE "\\[" "_CFORGE_BRACKET_OPEN" FILE_CONTENTS "${FILE_CONTENTS}")
    string(REGEX REPLACE "\\]" "_CFORGE_BRACKET_CLOSE" FILE_CONTENTS "${FILE_CONTENTS}")

    set(CURRENT_FILE_OBJECT "{ \"filename\": \"${FILE}\", \"blocks\": [] }")

    set(LINE_COUNTER 0)
    set(CURRENT_BLOCK 0)
    set(BLOCK_COUNT 0)
    foreach(LINE IN LISTS FILE_CONTENTS)
        math(EXPR LINE_COUNTER "${LINE_COUNTER} + 1")

        # Replace back the tokens with the brackets
        string(REGEX REPLACE "_CFORGE_BRACKET_OPEN" "[" LINE "${LINE}")
        string(REGEX REPLACE "_CFORGE_BRACKET_CLOSE" "]" LINE "${LINE}")

        message(DEBUG "| ${LINE_COUNTER}\t| ${LINE}")

        # Exclude empty lines
        if(LINE MATCHES "^[ \t\r]*$")
            message(DEBUG "Empty line")
            continue()
        endif()

        # Handle lines inside multiline comments (aka bracket comments)
        if(IN_BRACKET_COMMENT)
            # Search for a closing bracket on the line
            if(LINE MATCHES "${BRACKET_CLOSE_REGEX}")
                message(DEBUG "Ending comment block")
                unset(IN_BRACKET_COMMENT)
            else()
                message(DEBUG "In-block comment")
            endif()
            continue()
        endif()

        # Search for start of bracket comment
        # It must loop through all the line to detect and skip all open/close bracket pairs
        # If the last bracket on the line is an opening one, then this is a start of bracket comment
        # and IN_BRACKET_COMMENT will be set to TRUE
        # https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#bracket-comment
        if(LINE MATCHES "#${BRACKET_OPEN_REGEX}(.*)$")
            set(LINE_END "${CMAKE_MATCH_1}")
            set(SEARCH_FOR_CLOSING TRUE)
            set(CNT 0)
            while(LINE_END)
                if(SEARCH_FOR_CLOSING)
                    if(LINE_END MATCHES "${BRACKET_CLOSE_REGEX}(.*)$")
                        set(SEARCH_FOR_CLOSING FALSE)
                        set(LINE_END "${CMAKE_MATCH_1}")
                    else()
                        break()
                    endif()
                else()
                    if(LINE_END MATCHES "#${BRACKET_OPEN_REGEX}(.*)$")
                        set(SEARCH_FOR_CLOSING TRUE)
                        set(LINE_END "${CMAKE_MATCH_1}")
                    else()
                        break()
                    endif()
                endif()
                math(EXPR CNT "${CNT} + 1")
                # Reasonable threshold to stop iteration and avoid infinite loops
                # It is very unlikely that a single line will have more than 100 bracket opening/closing
                cforge_assert(CONDITION CNT LESS 100 MESSAGE "Infinite loop detected")
            endwhile()
            if(SEARCH_FOR_CLOSING)
                message(DEBUG "Starting comment block")
                set(IN_BRACKET_COMMENT TRUE)
            endif()
        endif()

        # Exclude single line comment
        if(LINE MATCHES "^[ \t\r]*#")
            message(DEBUG "Single line comment")
            continue()
        endif()

        # Exclude lines not starting with a command invocation
        # https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#source-files
        if(NOT LINE MATCHES "^[ \t\r]*[_a-zA-Z][_a-zA-Z0-9]*[ \t\r]*\\(.*$")
            message(DEBUG "Command continuation")
            continue()
        endif()

        # Register first executable line in if/elseif/else block for branch coverage
        if(INSIDE_BRANCH)
            string(JSON FIRST_EXEC_LINE GET "${CURRENT_FILE_OBJECT}"
                blocks ${CURRENT_BLOCK_INDEX} branches ${CURRENT_BRANCH_INDEX} first_exec_line
            )
            if(FIRST_EXEC_LINE EQUAL 0)
                string(JSON CURRENT_FILE_OBJECT SET "${CURRENT_FILE_OBJECT}"
                    blocks ${CURRENT_BLOCK_INDEX} branches ${CURRENT_BRANCH_INDEX} first_exec_line ${LINE_COUNTER}
                )
            endif()
        endif()

        # Compute executable branches
        if(LINE MATCHES "^[ \t\r]*if[ \t\r]*\\(")
            set(CURRENT_BLOCK_OBJECT "{ \"line\": ${LINE_COUNTER}, \"branches\": [] }")
            cforge_json_append(OUT CURRENT_FILE_OBJECT INDEX CURRENT_BLOCK_INDEX
                JSON "${CURRENT_FILE_OBJECT}" MEMBER blocks VALUE "${CURRENT_BLOCK_OBJECT}"
            )
            set(CURRENT_BRANCH_OBJECT "{ \"line\": ${LINE_COUNTER}, \"first_exec_line\": 0, \"type\": \"if\" }")
            cforge_json_append(OUT CURRENT_FILE_OBJECT INDEX CURRENT_BRANCH_INDEX
                JSON "${CURRENT_FILE_OBJECT}" MEMBER blocks ${CURRENT_BLOCK_INDEX} branches VALUE "${CURRENT_BRANCH_OBJECT}"
            )
            set(INSIDE_BRANCH TRUE)
        endif()
        if(LINE MATCHES "^[ \t\r]*(else(if)?)[ \t\r]*\\(")
            set(CURRENT_BRANCH_OBJECT "{ \"line\": ${LINE_COUNTER}, \"first_exec_line\": 0, \"type\": \"${CMAKE_MATCH_1}\"}")
            cforge_json_append(OUT CURRENT_FILE_OBJECT INDEX CURRENT_BRANCH_INDEX
                JSON "${CURRENT_FILE_OBJECT}" MEMBER blocks ${CURRENT_BLOCK_INDEX} branches VALUE "${CURRENT_BRANCH_OBJECT}"
            )
            set(INSIDE_BRANCH TRUE)
            if(CMAKE_MATCH_1 STREQUAL "else")
                set(ELSE_BRANCH_PARSED TRUE)
            endif()
        endif()
        if(LINE MATCHES "^[ \t\r]*endif[ \t\r]*\\(")
            if(NOT ELSE_BRANCH_PARSED) # Implicit else branch
                set(CURRENT_BRANCH_OBJECT "{ \"line\": ${LINE_COUNTER}, \"first_exec_line\": 0, \"type\": \"implicit-else\"}")
                cforge_json_append(OUT CURRENT_FILE_OBJECT INDEX CURRENT_BRANCH_INDEX
                    JSON "${CURRENT_FILE_OBJECT}" MEMBER blocks ${CURRENT_BLOCK_INDEX} branches VALUE "${CURRENT_BRANCH_OBJECT}"
                )
            endif()
            math(EXPR CURRENT_BLOCK_INDEX "${CURRENT_BLOCK_INDEX} - 1")
            cforge_assert(CONDITION CURRENT_BLOCK_INDEX GREATER_EQUAL -1 MESSAGE "Syntax error in file")
            set(INSIDE_BRANCH FALSE)
        endif()

        # Exclude else statements since they do not appear in CMake traces
        if(LINE MATCHES "^[ \t\r]*else[ \t\r]*\\(")
            message(DEBUG "Else")
            continue()
        endif()

        # Exclude lines ending control blocks
        if(LINE MATCHES "^[ \t\r]*end([a-z]*)")
            message(DEBUG "End of block: ${CMAKE_MATCH_1}")
            continue()
        endif()

        # Mark this line as executable since all previous exclusion checks didn't pass
        list(APPEND EXECUTABLE_LINES ${LINE_COUNTER})
    endforeach()

    set(_CFORGE_UNIT_COVERAGE_EXECUTABLE_LINES_FOR_${FILE} "${EXECUTABLE_LINES}" CACHE INTERNAL "" FORCE)
    # Make the JSON object one line and remove all spaces for compression
    string(REGEX REPLACE "[ \n]+" "" CURRENT_FILE_OBJECT "${CURRENT_FILE_OBJECT}")
    set(_CFORGE_UNIT_COVERAGE_EXECUTABLE_BRANCHES_FOR_${FILE} "${CURRENT_FILE_OBJECT}" CACHE INTERNAL "" FORCE)
endfunction()

# Get hit lines for trace file TRACEFILE
# Set multiple CACHE variable to store the coverage info:
#     _CFORGE_UNIT_COVERAGE_HIT_LINE_${FILENAME}_${LINENO}: the line LINENO in file FILENAME was hit
#     _CFORGE_UNIT_COVERAGE_HIT_BRANCH_${FILENAME}_${LINENO}: the branch at LINENO in file FILENAME was hit
function(_cforge_unit_coverage_get_hit_lines TRACEFILE)
    file(STRINGS "${TRACEFILE}" TRACEFILE_CONTENTS)
    # Same issue with bracket handling in lists
    string(REGEX REPLACE "\\[" "_CFORGE_BRACKET_OPEN" TRACEFILE_CONTENTS "${TRACEFILE_CONTENTS}")
    string(REGEX REPLACE "\\]" "_CFORGE_BRACKET_CLOSE" TRACEFILE_CONTENTS "${TRACEFILE_CONTENTS}")
    foreach(TRACELINE ${TRACEFILE_CONTENTS})
        string(REGEX REPLACE "_CFORGE_BRACKET_OPEN" "[" LINE "${LINE}")
        string(REGEX REPLACE "_CFORGE_BRACKET_CLOSE" "]" LINE "${LINE}")

        string(REGEX MATCH "^(.+)\\(([0-9]+)\\):  (.*)$" _ ${TRACELINE})
        # TODO Handle error (should not happen though)
        set(FILENAME ${CMAKE_MATCH_1})
        set(LINENO ${CMAKE_MATCH_2})
        set(LINE_CONTENT ${CMAKE_MATCH_3})

        foreach(ENTRY IN LISTS _CFORGE_UNIT_COVERAGE_INCLUDE)
            cmake_path(IS_PREFIX ENTRY "${FILENAME}" NORMALIZE IS_FILENAME_INCLUDED)
            if(IS_FILENAME_INCLUDED)
                break()
            endif()
        endforeach()

        if(NOT IS_FILENAME_INCLUDED)
            message(DEBUG "Skipping ${FILENAME}")
            continue()
        endif()

        if(NOT _CFORGE_UNIT_COVERAGE_EXECUTABLE_LINES_FOR_${FILENAME})
            message(DEBUG "File '${FILENAME}' not yet analyzed, getting executable lines and branches")
            _cforge_unit_coverage_get_executable_lines("${FILENAME}")
        else()
            # File already analyzed, skipping
            # Logging is done in the if part above because the else part occurs far too often
        endif()

        # Compute line hit
        set(LINE_HIT_VARIABLE "_CFORGE_UNIT_COVERAGE_HIT_LINE_${FILENAME}_${LINENO}")
        if(NOT DEFINED ${LINE_HIT_VARIABLE})
            set(${LINE_HIT_VARIABLE} 0)
        endif()
        math(EXPR "${LINE_HIT_VARIABLE}" "${${LINE_HIT_VARIABLE}} + 1")
        set(${LINE_HIT_VARIABLE} ${${LINE_HIT_VARIABLE}} CACHE INTERNAL "" FORCE)

        # Compute branch hit
        set(BRANCH_HIT_VARIABLE "_CFORGE_UNIT_COVERAGE_HIT_BRANCH_${FILENAME}_${LINENO}")
        if(LINE_CONTENT MATCHES "^[ \t\r]*(if|else(if)?)[ \t\r]*\\(")
            if(NOT DEFINED ${BRANCH_HIT_VARIABLE})
                set(${BRANCH_HIT_VARIABLE} 0)
            endif()
            math(EXPR "${BRANCH_HIT_VARIABLE}" "${${BRANCH_HIT_VARIABLE}} + 1")
            set(${BRANCH_HIT_VARIABLE} ${${BRANCH_HIT_VARIABLE}} CACHE INTERNAL "" FORCE)
        endif()
    endforeach()
endfunction()

# Fill the variable REPORT with the branch coverage information for source file FILENAME
function(_cforge_unit_coverage_generate_lcov_branch_report_for_file FILENAME REPORT)
    # TODO Handle '-' when the block containing the branch is never executed
    # Iterate over all blocks
    cforge_json_get_array_as_list(RESULT_VARIABLE BLOCKS JSON "${_CFORGE_UNIT_COVERAGE_EXECUTABLE_BRANCHES_FOR_${FILENAME}}" MEMBER blocks)
    set(BLOCK_INDEX 0)
    set(BRANCH_INDEX 0)
    foreach(BLOCK IN LISTS BLOCKS)
        string(JSON BLOCK_LINE GET "${BLOCK}" line)
        # Iterate over all branches in that block
        cforge_json_get_array_as_list(RESULT_VARIABLE BRANCHES JSON "${BLOCK}" MEMBER branches)
        set(BRANCH_INDEX 0)
        foreach(BRANCH IN LISTS BRANCHES)
            string(JSON BRANCH_LINE GET "${BRANCH}" line)
            string(JSON FIRST_EXEC_LINE GET "${BRANCH}" first_exec_line)
            string(JSON BRANCH_TYPE GET "${BRANCH}" type)
            set(BRANCH_HIT_VARIABLE "_CFORGE_UNIT_COVERAGE_HIT_BRANCH_${FILENAME}_${BRANCH_LINE}")
            set(FIRST_LINE_HIT_VARIABLE "_CFORGE_UNIT_COVERAGE_HIT_LINE_${FILENAME}_${FIRST_EXEC_LINE}")
            # Must check the branch and its first executed line since cmake --trace
            # reports all if/elseif/else lines even if not evaluated to true
            if(NOT "${${BRANCH_HIT_VARIABLE}}" OR NOT "${${FIRST_LINE_HIT_VARIABLE}}")
                set(HIT_COUNT 0) # Branch was not hit
            else()
                set(HIT_COUNT ${${FIRST_LINE_HIT_VARIABLE}})
                math(EXPR BRANCH_HIT "${BRANCH_HIT} + 1")
            endif()
            # Handle implicit-else case separatly as it is not reported in the traces
            if(BRANCH_TYPE STREQUAL "implicit-else")
                block(PROPAGATE HIT_COUNT)
                    # Get previous block
                    math(EXPR PREVIOUS_BRANCH_INDEX "${BRANCH_INDEX} - 1")
                    list(GET BRANCHES ${PREVIOUS_BRANCH_INDEX} PREVIOUS_BRANCH)
                    # Get previous branch line number and hit count
                    string(JSON PREVIOUS_BRANCH_LINE GET "${PREVIOUS_BRANCH}" line)
                    set(PREVIOUS_BRANCH_HIT_VARIABLE "_CFORGE_UNIT_COVERAGE_HIT_BRANCH_${FILENAME}_${PREVIOUS_BRANCH_LINE}")
                    if(NOT ${PREVIOUS_BRANCH_HIT_VARIABLE})
                        set(${PREVIOUS_BRANCH_HIT_VARIABLE} 0)
                    endif()
                    # Get previous branch first executed line number and hit count
                    string(JSON PREVIOUS_FIRST_EXEC_LINE GET "${PREVIOUS_BRANCH}" first_exec_line)
                    set(PREVIOUS_FIRST_LINE_HIT_VARIABLE "_CFORGE_UNIT_COVERAGE_HIT_LINE_${FILENAME}_${PREVIOUS_FIRST_EXEC_LINE}")
                    if(NOT ${PREVIOUS_FIRST_LINE_HIT_VARIABLE})
                        set(${PREVIOUS_FIRST_LINE_HIT_VARIABLE} 0)
                    endif()
                    # Substract the previous branch hit count with its first executed line hit count
                    math(EXPR HIT_COUNT "${${PREVIOUS_BRANCH_HIT_VARIABLE}} - ${${PREVIOUS_FIRST_LINE_HIT_VARIABLE}}")
                endblock()
            endif()
            list(APPEND ${REPORT} "BRDA:${BLOCK_LINE},${BLOCK_INDEX},${BRANCH_INDEX},${HIT_COUNT}")
            math(EXPR BRANCH_INDEX "${BRANCH_INDEX} + 1")
        endforeach()
        math(EXPR BLOCK_INDEX "${BLOCK_INDEX} + 1")
    endforeach()
    list(APPEND ${REPORT}
        "BRH:${BRANCH_HIT}"
        "BRF:${BRANCH_INDEX}"
    )
    set(${REPORT} "${${REPORT}}" PARENT_SCOPE)
endfunction()

# Fill the variable REPORT with the line coverage information for source file FILENAME
function(_cforge_unit_coverage_generate_lcov_line_report_for_file FILENAME REPORT)
    list(LENGTH _CFORGE_UNIT_COVERAGE_EXECUTABLE_LINES_FOR_${FILENAME} LINE_FOUND)
    set(LINE_HIT 0)
    foreach(EXECUTABLE_LINE ${_CFORGE_UNIT_COVERAGE_EXECUTABLE_LINES_FOR_${FILENAME}})
        set(HIT_VARIABLE "_CFORGE_UNIT_COVERAGE_HIT_LINE_${FILENAME}_${EXECUTABLE_LINE}")
        if(NOT "${${HIT_VARIABLE}}")
            set(HIT_COUNT 0)
        else()
            set(HIT_COUNT ${${HIT_VARIABLE}})
            math(EXPR LINE_HIT "${LINE_HIT} + 1")
        endif()
        list(APPEND ${REPORT} "DA:${EXECUTABLE_LINE},${HIT_COUNT}")
    endforeach()
    list(APPEND ${REPORT}
        "LH:${LINE_HIT}"
        "LF:${LINE_FOUND}"
    )
    set(${REPORT} "${${REPORT}}" PARENT_SCOPE)
endfunction()

# Generate a lcov coverage report for TRACEFILE and write it to LCOV_OUTPUT
function(_cforge_unit_coverage_generate_lcov_report TRACEFILE LCOV_OUTPUT)
    _cforge_unit_coverage_get_hit_lines(${TRACEFILE})
    foreach(FILENAME ${_CFORGE_UNIT_COVERAGE_FILES})
        unset(BRANCH_COVERAGE_REPORT)
        _cforge_unit_coverage_generate_lcov_branch_report_for_file("${FILENAME}" BRANCH_COVERAGE_REPORT)
        unset(LINE_COVERAGE_REPORT)
        _cforge_unit_coverage_generate_lcov_line_report_for_file("${FILENAME}" LINE_COVERAGE_REPORT)
        list(APPEND COVERAGE_REPORT
            "SF:${FILENAME}"
            "${BRANCH_COVERAGE_REPORT}"
            "${LINE_COVERAGE_REPORT}"
            "end_of_record\n"
        )
        string(REPLACE ";" "\n" COVERAGE_REPORT "${COVERAGE_REPORT}")
    endforeach()
    file(WRITE "${LCOV_OUTPUT}" ${COVERAGE_REPORT})
endfunction()

# Collect trace files in BINARY_DIR and generate a lcov report for each one
function(_cforge_unit_coverage_generate_all_lcov_reports BINARY_DIR)
    file(GLOB_RECURSE TRACEFILES LIST_DIRECTORIES false ${BINARY_DIR}/*cforge-unit-coverage-traces.txt)
    foreach(TRACEFILE IN LISTS TRACEFILES)
        get_filename_component(TRACEFILE_DIR "${TRACEFILE}" DIRECTORY)
        _cforge_unit_coverage_generate_lcov_report("${TRACEFILE}" "${TRACEFILE_DIR}/cforge-unit-coverage-report.txt")
    endforeach()
endfunction()

# Collect lcov reports in BINARY_DIR and generate a html report
function(_cforge_unit_coverage_generate_html_report SOURCE_DIR BINARY_DIR RESULT_VAR)
    set(OUTPUT_DIR "${BINARY_DIR}/CoverageHtmlReport")
    # Cleanup coverage output directory
    file(REMOVE_RECURSE "${OUTPUT_DIR}")
    file(MAKE_DIRECTORY "${OUTPUT_DIR}")
    # Find all generated coverage reports
    file(GLOB_RECURSE REPORTS LIST_DIRECTORIES false ${BINARY_DIR}/*cforge-unit-coverage-report.txt)
    # Convert CMake paths to native paths before genhtml execution
    file(TO_NATIVE_PATH "${SOURCE_DIR}" NATIVE_SOURCE_DIR)
    file(TO_NATIVE_PATH "${OUTPUT_DIR}" NATIVE_OUTPUT_DIR)
    execute_process(
        COMMAND
            ${GenHTML_EXECUTABLE} --output-directory "${NATIVE_OUTPUT_DIR}"
                --rc genhtml_branch_coverage=1
                --rc genhtml_dark_mode=1 # Added in lcov 1.16, ignored if not supported
                --rc genhtml_hierarchical=1 # Added in lcov 1.16, ignored if not supported
                --no-function-coverage
                ${REPORTS}
        WORKING_DIRECTORY "${NATIVE_SOURCE_DIR}"
        COMMAND_ECHO STDOUT
        OUTPUT_VARIABLE GENHTML_OUTPUT
        ECHO_OUTPUT_VARIABLE
        RESULT_VARIABLE RESULT
    )
    if(NOT RESULT EQUAL 0)
        message(SEND_ERROR "genhtml finished with errors")
    endif()
    string(REGEX REPLACE ".*branches[.]+: ([0-9.]+).*" "\\1" BRANCH_COVERAGE "${GENHTML_OUTPUT}")
    string(REGEX REPLACE ".*lines[.]+: ([0-9.]+).*" "\\1" LINE_COVERAGE "${GENHTML_OUTPUT}")
    set(${RESULT_VAR} "line:${LINE_COVERAGE} branch:${BRANCH_COVERAGE}" PARENT_SCOPE)
endfunction()

function(_cforge_unit_coverage_cleanup_cache)
    get_directory_property(VARIABLES CACHE_VARIABLES)
    foreach(VARIABLES ${VARIABLES})
        if(VARIABLES MATCHES "^_CFORGE_UNIT_COVERAGE_.*")
            unset(${VARIABLES} CACHE)
        endif()
    endforeach()
endfunction()

# Collect lcov reports in BINARY_DIR and generate an html report
function(cforge_unit_coverage_generate_coverage_report)
    cmake_parse_arguments(ARG "" "SOURCE_DIR;BINARY_DIR;RESULT_VAR" "INCLUDE" ${ARGN})
    cforge_assert(CONDITION DEFINED ARG_SOURCE_DIR MESSAGE "SOURCE_DIR argument is required")
    cforge_assert(CONDITION DEFINED ARG_BINARY_DIR MESSAGE "BINARY_DIR argument is required")
    _cforge_unit_coverage_cleanup_cache()
    if(NOT ARG_INCLUDE)
        set(_CFORGE_UNIT_COVERAGE_INCLUDE "${ARG_SOURCE_DIR}")
    else()
        set(_CFORGE_UNIT_COVERAGE_INCLUDE "${ARG_INCLUDE}")
    endif()
    _cforge_unit_coverage_generate_all_lcov_reports("${ARG_BINARY_DIR}")
    _cforge_unit_coverage_generate_html_report("${ARG_SOURCE_DIR}" "${ARG_BINARY_DIR}" COVERAGE_RESULT_SUMMARY)
    if(ARG_RESULT_VAR)
        set(${ARG_RESULT_VAR} "${COVERAGE_RESULT_SUMMARY}" PARENT_SCOPE)
    endif()
endfunction()

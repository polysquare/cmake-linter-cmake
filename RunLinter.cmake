# /RunLinter.cmake
#
# A wrapper around linters which can treat a
# positive exit status as a non-error.
#
# See /LICENCE.md for Copyright information

set (EXECUTABLE "" CACHE STRING "")
set (SOURCES "" CACHE STRING "")
set (OPTIONS "" CACHE STRING "")
set (VERBOSE "" CACHE STRING "")
set (WARN_ONLY "" CACHE STRING "")
set (SOURCES_LAST "" CACHE STRING "")

if (NOT EXECUTABLE)

    message (FATAL_ERROR "EXECUTABLE not specified. "
                         "This is a bug in CMakeLinter.cmake")

endif ()

if (NOT SOURCES)

    message (FATAL_ERROR "SOURCES not specified. "
                         "This is a bug in CMakeLinter.cmake")

endif ()

# Convert from "`" as a delimiter to ";"
string (REPLACE "`" ";" OPTIONS "${OPTIONS}")
string (REPLACE "`" ";" SOURCES "${SOURCES}")

if (NOT SOURCES_LAST)
    set (LINTER_COMMAND_LINE
         "${EXECUTABLE}"
         ${SOURCES}
         ${OPTIONS})
else ()
    set (LINTER_COMMAND_LINE
         "${EXECUTABLE}"
         ${OPTIONS}
         ${SOURCES})
endif ()

string (REPLACE ";" " " LINTER_PRINTED_COMMAND_LINE
        "${LINTER_COMMAND_LINE}")

if (VERBOSE)
    message (STATUS "${LINTER_PRINTED_COMMAND_LINE}")
endif ()

execute_process (COMMAND
                 ${LINTER_COMMAND_LINE}
                 RESULT_VARIABLE RESULT
                 OUTPUT_VARIABLE OUTPUT
                 ERROR_VARIABLE ERROR
                 OUTPUT_STRIP_TRAILING_WHITESPACE
                 ERROR_STRIP_TRAILING_WHITESPACE)

if (NOT RESULT EQUAL 0)

    message ("${OUTPUT}")
    message ("${ERROR}")
    if (NOT WARN_ONLY)
        set (MESSAGE
             "${LINTER_PRINTED_COMMAND_LINE} found issues with ${SOURCES} ")
        set (MESSAGE "${MESSAGE} exiting with ${RESULT}")
        message (FATAL_ERROR "${MESSAGE}")
    endif ()

endif ()

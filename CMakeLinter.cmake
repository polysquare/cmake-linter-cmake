# /CMakeLinter.cmake
#
# Lint specified files for style guide violations.
#
# See /LICENCE.md for Copyright information

include (CMakeParseArguments)
include ("cmake/cmake-forward-arguments/ForwardArguments")
include ("cmake/tooling-cmake-util/PolysquareToolingUtil")

set (_CMAKE_LINT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

macro (cmake_lint_validate CONTINUE)

    if (NOT DEFINED PSQ_CMAKE_LINT_FOUND OR
        NOT DEFINED CMAKELINT_FOUND)

        set (CMAKE_MODULE_PATH
             ${CMAKE_MODULE_PATH} # NOLINT:correctness/quotes
             "${_CMAKE_LINT_LIST_DIR}")
        find_package (PSQCMAKELINTER ${ARGN})
        find_package (CMAKELINT ${ARGN})

    endif ()

    if (PSQ_CMAKE_LINT_FOUND AND CMAKELINT_FOUND)
        set (${CONTINUE} TRUE)
    else ()
        set (${CONTINUE} FALSE)
    endif ()

endmacro ()

function (_cmake_lint_get_psq_commandline COMMANDLINE_RETURN)

    set (COMMANDLINE_OPTION_ARGS WARN_ONLY)
    set (COMMANDLINE_SINGLEVAR_ARGS INDENT NAMESPACE)
    set (COMMANDLINE_MULTIVAR_ARGS SOURCES BLACKLIST WHITELIST)

    cmake_parse_arguments (COMMANDLINE
                           "${COMMANDLINE_OPTION_ARGS}"
                           "${COMMANDLINE_SINGLEVAR_ARGS}"
                           "${COMMANDLINE_MULTIVAR_ARGS}"
                           ${ARGN})

    if (COMMANDLINE_WARN_ONLY)
        set (WARN_ONLY_STATE ON)
    else ()
        set (WARN_ONLY_STATE OFF)
    endif ()

    set (COMMANDLINE_OPTIONS "")

    if (COMMANDLINE_BLACKLIST)
        list (APPEND COMMANDLINE_OPTIONS --blacklist ${COMMANDLINE_BLACKLIST})
    endif ()

    if (COMMANDLINE_WHITELIST)
        list (APPEND COMMANDLINE_OPTIONS --whitelist ${COMMANDLINE_WHITELIST})
    endif ()

    if (COMMANDLINE_INDENT)
        list (APPEND COMMANDLINE_OPTIONS --indent ${COMMANDLINE_INDENT})
    else ()
        list (APPEND COMMANDLINE_OPTIONS --indent 4)
    endif ()

    if (COMMANDLINE_NAMESPACE)
        list (APPEND COMMANDLINE_OPTIONS --namespace ${COMMANDLINE_NAMESPACE})
    endif ()

    string (REPLACE ";" "`" COMMANDLINE_OPTIONS "${COMMANDLINE_OPTIONS}")
    string (REPLACE ";" "`" COMMANDLINE_SOURCES "${COMMANDLINE_SOURCES}")

    set (${COMMANDLINE_RETURN}
         "${CMAKE_COMMAND}"
         "-DVERBOSE=OFF"
         "-DWARN_ONLY=${WARN_ONLY_STATE}"
         "-DEXECUTABLE=${PSQ_CMAKE_LINT_EXECUTABLE}"
         "-DSOURCES=${COMMANDLINE_SOURCES}"
         "-DOPTIONS=${COMMANDLINE_OPTIONS}"
         -P
         "${_CMAKE_LINT_LIST_DIR}/RunLinter.cmake"
         PARENT_SCOPE)

endfunction ()

function (_cmake_lint_get_cmakelint_commandline COMMANDLINE_RETURN)

    set (COMMANDLINE_OPTION_ARGS WARN_ONLY)
    set (COMMANDLINE_SINGLEVAR_ARGS SPACES)
    set (COMMANDLINE_MULTIVAR_ARGS SOURCES FILTER)

    cmake_parse_arguments (COMMANDLINE
                           "${COMMANDLINE_OPTION_ARGS}"
                           "${COMMANDLINE_SINGLEVAR_ARGS}"
                           "${COMMANDLINE_MULTIVAR_ARGS}"
                           ${ARGN})

    if (COMMANDLINE_WARN_ONLY)
        set (WARN_ONLY_STATE ON)
    else ()
        set (WARN_ONLY_STATE OFF)
    endif ()

    set (COMMANDLINE_OPTIONS "${CMAKELINT_EXECUTABLE}")

    if (COMMANDLINE_FILTER)
        string (REPLACE ";" "," COMMANDLINE_FILTER "${COMMANDLINE_FILTER}")
        list (APPEND COMMANDLINE_OPTIONS --filter=${COMMANDLINE_FILTER})
    endif ()

    if (COMMANDLINE_SPACES)
        list (APPEND COMMANDLINE_OPTIONS --spaces=${COMMANDLINE_SPACES})
    else ()
        list (APPEND COMMANDLINE_OPTIONS --spaces=4)
    endif ()

    string (REPLACE ";" "`" COMMANDLINE_OPTIONS "${COMMANDLINE_OPTIONS}")
    string (REPLACE ";" "`" COMMANDLINE_SOURCES "${COMMANDLINE_SOURCES}")

    set (${COMMANDLINE_RETURN}
         "${CMAKE_COMMAND}"
         "-DVERBOSE=OFF"
         "-DWARN_ONLY=${WARN_ONLY_STATE}"
         "-DSOURCES_LAST=ON"
         "-DEXECUTABLE=${PYTHON_EXECUTABLE}"
         "-DSOURCES=${COMMANDLINE_SOURCES}"
         "-DOPTIONS=${COMMANDLINE_OPTIONS}"
         -P
         "${_CMAKE_LINT_LIST_DIR}/RunLinter.cmake"
         PARENT_SCOPE)

endfunction ()

function (_cmake_lint_check_each_source TARGET)

    set (ADD_NORMAL_CHECK_OPTION_ARGS WARN_ONLY)
    set (ADD_NORMAL_CHECK_SINGLEVAR_ARGS NAMESPACE INDENT)
    set (ADD_NORMAL_CHECK_MULTIVAR_ARGS PSQ_BLACKLIST
                                        PSQ_WHITELIST
                                        CMAKELINT_BLACKLIST
                                        CMAKELINT_WHITELIST
                                        SOURCES
                                        DEPENDS)

    cmake_parse_arguments (ADD_CHECKS
                           "${ADD_NORMAL_CHECK_OPTION_ARGS}"
                           "${ADD_NORMAL_CHECK_SINGLEVAR_ARGS}"
                           "${ADD_NORMAL_CHECK_MULTIVAR_ARGS}"
                           ${ARGN})

    # Generate a FILTER option by iterating over CMAKELINT_WHITELIST
    # and CMAKELINT_BLACKLIST
    set (ADD_CHECKS_FILTER "")
    foreach (CHECK ${ADD_CHECKS_CMAKELINT_BLACKLIST})
        list (APPEND ADD_CHECKS_FILTER "-${CHECK}")
    endforeach ()

    foreach (CHECK ${ADD_CHECKS_CMAKELINT_WHITELIST})
        list (APPEND ADD_CHECKS_FILTER "+${CHECK}")
    endforeach ()

    # Set the options necessary for cmakelint
    set (ADD_CHECKS_SPACES ${ADD_CHECKS_INDENT})  # NOLINT:unused/var_in_func

    # Set the options necessary for polysquare-cmake-linter
    set (ADD_CHECKS_BLACKLIST  # NOLINT:unused/var_in_func
         ${ADD_CHECKS_PSQ_BLACKLIST})
    set (ADD_CHECKS_WHITELIST  # NOLINT:unused/var_in_func
         ${ADD_CHECKS_PSQ_WHITELIST})

    # Get a commandline for polysquare-cmake-linter
    cmake_forward_arguments (ADD_CHECKS
                             GET_PSQ_CL_FWD_OPTS
                             OPTION_ARGS WARN_ONLY
                             SINGLEVAR_ARGS NAMESPACE
                                            INDENT
                             MULTIVAR_ARGS BLACKLIST
                                           WHITELIST)

    # Get a commandline for cmakelint
    cmake_forward_arguments (ADD_CHECKS
                             GET_CMAKELINT_CL_FWD_OPTS
                             OPTION_ARGS WARN_ONLY
                             SINGLEVAR_ARGS SPACES
                             MULTIVAR_ARGS FILTER)

    # Now run the tool on the source, passing everything after DEPENDS
    cmake_forward_arguments (ADD_CHECKS
                             RUN_TOOL_ON_SOURCE_FORWARD
                             MULTIVAR_ARGS DEPENDS)

    foreach (SOURCE ${ADD_CHECKS_SOURCES})
        _cmake_lint_get_psq_commandline (PSQ_COMMAND
                                         SOURCES "${SOURCE}"
                                         ${GET_PSQ_CL_FWD_OPTS})
        _cmake_lint_get_cmakelint_commandline (CMAKELINT_COMMAND
                                               SOURCES "${SOURCE}"
                                               ${GET_CMAKELINT_CL_FWD_OPTS})
        psq_run_tool_on_source (${TARGET} "${SOURCE}"
                                "polysquare-cmake-linter"
                                COMMAND ${PSQ_COMMAND}
                                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                                ${RUN_TOOL_ON_SOURCE_FORWARD})
        psq_run_tool_on_source (${TARGET} "${SOURCE}"
                                "cmakelint"
                                COMMAND ${CMAKELINT_COMMAND}
                                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                                ${RUN_TOOL_ON_SOURCE_FORWARD})
    endforeach ()

endfunction ()

# cmake_lint_sources
#
# Run polysquare-generic-file-linter on all the specified sources on a target
# called TARGET. Note that this does not check TARGET's sources, but rather
# checks the specified sources once TARGET is run.
#
# TARGET : Target to check sources on
# [Optional] WARN_ONLY : Don't error out, just warn on potential problems.
# [Optional] CHECK_GENERATED : Check generated files too.
# [Optional] PSQ_WHITELIST : Only run these checks from
#                            polysquare-cmake-linter
# [Optional] PSQ_BLACKLIST : Don't run these checks from
#                            polysquare-cmake-linter
# [Optional] CMAKELINT_WHITELIST : Run these checks from cmakelint
# [Optional] CMAKELINT_BLACKLIST : Don't run these checks from cmakelint
# [Optional] NAMESPACE : The namespace cmake functions will use
# [Optional] INDENT : The indentation cmake functions will use, default is 4
# [Optional] DEPENDS : Targets or source files to depend on.
function (cmake_lint_sources TARGET)

    cmake_lint_validate (CMAKE_LINT_AVAILABLE)

    if (NOT CMAKE_LINT_AVAILABLE)

        add_custom_target (${TARGET})
        return ()

    endif ()

    set (OPTIONAL_OPTIONS
         WARN_ONLY
         CHECK_GENERATED
         ADD_TO_ALL)
    set (SINGLEVALUE_OPTIONS
         NAMESPACE
         INDENT)
    set (MULTIVALUE_OPTIONS
         SOURCES
         PSQ_WHITELIST
         PSQ_BLACKLIST
         CMAKELINT_WHITELIST
         CMAKELINT_BLACKLIST
         DEPENDS)
    cmake_parse_arguments (CMAKE_LINT
                           "${OPTIONAL_OPTIONS}"
                           "${SINGLEVALUE_OPTIONS}"
                           "${MULTIVALUE_OPTIONS}"
                           ${ARGN})

    psq_handle_check_generated_option (CMAKE_LINT FILTERED_CHECK_SOURCES
                                       SOURCES ${CMAKE_LINT_SOURCES})

    psq_assert_set (FILTERED_CHECK_SOURCES
                    "SOURCES must be set to either native sources "
                    "or generated sources with the CHECK_GENERATED flag set "
                    "when using cmake_lint_sources")

    cmake_forward_arguments (CMAKE_LINT ADD_CHECKS_TO_TARGET_FORWARD
                             OPTION_ARGS WARN_ONLY
                             SINGLEVAR_ARGS ${SINGLEVALUE_OPTIONS}
                             MULTIVAR_ARGS ${MULTIVALUE_OPTIONS})

    add_custom_target (${TARGET} SOURCES ${CMAKE_LINT_SOURCES})

    _cmake_lint_check_each_source (${TARGET} ${ADD_CHECKS_TO_TARGET_FORWARD})

endfunction ()

# cmake_lint_target_sources
#
# Run cmake linters on all the sources for a particular TARGET,
# reporting any warnings or errors on stderr
#
# TARGET : Target to check sources on
# [Optional] WARN_ONLY : Don't error out, just warn on potential problems.
# [Optional] CHECK_GENERATED : Check generated files too.
# [Optional] PSQ_WHITELIST : Only run these checks from
#                            polysquare-cmake-linter
# [Optional] PSQ_BLACKLIST : Don't run these checks from
#                            polysquare-cmake-linter
# [Optional] CMAKELINT_WHITELIST : Run these checks from cmakelint
# [Optional] CMAKELINT_BLACKLIST : Don't run these checks from cmakelint
# [Optional] NAMESPACE : The namespace cmake functions will use
# [Optional] INDENT : The indentation cmake functions will use, default is 4
# [Optional] DEPENDS : Targets or source files to depend on.
function (cmake_lint_target_sources TARGET)

    psq_strip_extraneous_sources (files_to_check ${TARGET})
    cmake_lint_sources (${TARGET}
                        SOURCES ${files_to_check}
                        ${ARGN})

endfunction ()

# /FindCMAKELINT.cmake
#
# This CMake script will search for cmakelint and set the
# following variables
#
# CMAKELINT_FOUND : Whether or not cmakelint is available on the target system
# CMAKELINT_EXECUTABLE : Fully qualified path to the cmakelint executable
#
# The following variables will affect the operation of this script
# CMAKELINT_SEARCH_PATHS : List of directories to search for cmakelint in,
#                          before searching any system paths.
#
# See /LICENCE.md for Copyright information

include ("cmake/tooling-find-pkg-util/ToolingFindPackageUtil")

find_package (PythonInterp)

function (cmake_lint_cmake_linter_cmakelint_find)

    if (DEFINED CMAKELINT_FOUND)

        return ()

    endif ()

    # Set-up the directory tree of the cmakelint
    # installation
    set (BIN_SUBDIR bin)
    set (CMAKELINT_EXECUTABLE cmakelint)

    psq_find_tool_executable ("${CMAKELINT_EXECUTABLE}"
                              CMAKELINT_EXECUTABLE
                              PATHS ${CMAKELINT_SEARCH_PATHS}
                              PATH_SUFFIXES "${BIN_SUBDIR}")

    psq_report_not_found_if_not_quiet (CMakeLint
                                       CMAKELINT_EXECUTABLE
                                       "The 'cmakelint' "
                                       "executable was not found "
                                       "in any search or system paths.\n.."
                                       "Please adjust "
                                       "CMAKELINT_SEARCH_PATHS "
                                       "to the installation prefix of the"
                                       "'cmakelint'\n.. "
                                       "executable or install"
                                       "cmakelint")

    psq_check_and_report_tool_version (CMakeLint
                                       "latest"
                                       REQUIRED_VARS
                                       CMAKELINT_EXECUTABLE
                                       PYTHON_EXECUTABLE)


    set (CMAKELINT_FOUND # NOLINT:style/set_var_case
         ${CMakeLint_FOUND}
         PARENT_SCOPE)

endfunction ()

cmake_lint_cmake_linter_cmakelint_find ()

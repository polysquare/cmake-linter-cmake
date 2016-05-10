# /FindPSQCMAKELINTER.cmake
#
# This CMake script will search for polysquare-cmake-linter and set the
# following variables
#
# PSQ_CMAKE_LINT_FOUND : Whether or not polysquare-cmake-linter
#                        is available on the target system
# PSQ_CMAKE_LINT_EXECUTABLE : Fully qualified path to the
#                             polysquare-cmake-linter executable
#
# The following variables will affect the operation of this script
# PSQ_CMAKE_LINT_SEARCH_PATHS : List of directories to search for
#                               polysquare-cmake-linter in,
#                               before searching any system paths.
#
# See /LICENCE.md for Copyright information

include ("cmake/tooling-find-pkg-util/ToolingFindPackageUtil")

function (cmake_lint_cmake_linter_find)

    if (DEFINED PSQ_CMAKE_LINT_FOUND)

        return ()

    endif ()

    # Set-up the directory tree of the polysquare-cmake-linter
    # installation
    set (BIN_SUBDIR bin)
    set (PSQ_CMAKE_LINT_EXECUTABLE polysquare-cmake-linter)

    psq_find_tool_executable ("${PSQ_CMAKE_LINT_EXECUTABLE}"
                              PSQ_CMAKE_LINT_EXECUTABLE
                              PATHS ${PSQ_CMAKE_LINT_SEARCH_PATHS}
                              PATH_SUFFIXES "${BIN_SUBDIR}")

    psq_report_not_found_if_not_quiet (PolysquareCMakeLinter
                                       PSQ_CMAKE_LINT_EXECUTABLE
                                       "The 'polysquare-cmake-linter' "
                                       "executable was not found "
                                       "in any search or system paths.\n.."
                                       "Please adjust "
                                       "PSQ_CMAKE_LINT_SEARCH_PATHS "
                                       "to the installation prefix of the"
                                       "'polysquare-cmake-linter'\n.. "
                                       "executable or install"
                                       "polysquare-cmake-linter")

    psq_check_and_report_tool_version (PolysquareCMakeLinter
                                       "latest"
                                       REQUIRED_VARS
                                       PSQ_CMAKE_LINT_EXECUTABLE)


    set (PSQ_CMAKE_LINT_FOUND # NOLINT:style/set_var_case
         ${PolysquareCMakeLinter_FOUND}
         PARENT_SCOPE)

endfunction ()

cmake_lint_cmake_linter_find ()

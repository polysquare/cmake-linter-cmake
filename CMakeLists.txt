# /CMakeLists.txt
#
# Main entry point for CMakeLinter tests.
#
# See /LICENCE.md for Copyright information

include ("${CMAKE_CURRENT_LIST_DIR}/conanbuildinfo.cmake")
set (CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_LIST_DIR}"
     ${CONAN_CMAKE_MODULE_PATH}  # NOLINT:correctness/quotes
     ${CMAKE_MODULE_PATH})  # NOLINT:correctness/quotes

cmake_minimum_required (VERSION 2.8)

include ("cmake/cmake-unit/CMakeUnitRunner")
include ("cmake/cmake-unit/CMakeUnit")
include (CMakeLinter)

if (NOT CMAKE_SCRIPT_MODE_FILE)

    cmake_lint_validate (HAVE_CMAKE_LINT)

else ()

    # Set these variables such that the conditions to add tests always pass
    # as we're not in the pre-configure phase, which is the only place
    # we'd want them to fail.
    set (HAVE_CMAKE_LINT TRUE)

endif ()

set (_CUR_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")
set (CMAKE_FILES
     "${_CUR_LIST_DIR}/CMakeLinter.cmake"
     "${_CUR_LIST_DIR}/RunLinter.cmake"
     "${_CUR_LIST_DIR}/FindPSQCMAKELINTER.cmake"
     "${_CUR_LIST_DIR}/FindCMAKELINT.cmake"
     "${_CUR_LIST_DIR}/CMakeLists.txt")
set (MARKDOWN_FILES
     "${CMAKE_CURRENT_LIST_DIR}/LICENSE.md"
     "${CMAKE_CURRENT_LIST_DIR}/README.md")

cmake_unit_init (NAMESPACE cmake_lint
                 COVERAGE_FILES ${CMAKE_FILES})

cmake_lint_sources (cmakelint
                    CMAKELINT_BLACKLIST "whitespace/extra"
                                        "package/consistency"
                                        "whitespace/indent"
                    NAMESPACE cmake_lint
                    SOURCES ${CMAKE_FILES})

add_custom_target (analysis ALL DEPENDS cmakelint)

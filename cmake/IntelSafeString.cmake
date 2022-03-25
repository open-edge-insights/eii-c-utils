# Copyright (c) 2019 Intel Corporation.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

set(INTEL_SAFESTRING_DIR "${CMAKE_CURRENT_BINARY_DIR}/IntelSafeString")

set (MAX_SAFESTRING_SIZE "60")

# Download Intel Safe String library source code
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/IntelSafeString.txt.in"
    "${INTEL_SAFESTRING_DIR}/safestring-download/CMakeLists.txt")
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
                RESULT_VARIABLE ss_result
                WORKING_DIRECTORY ${INTEL_SAFESTRING_DIR}/safestring-download)
if(ss_result)
    message(FATAL_ERROR "CMake step for safestring failed: ${ss_result}")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build .
    RESULT_VARIABLE ss_result
    WORKING_DIRECTORY ${INTEL_SAFESTRING_DIR}/safestring-download)
if(result)
    message(FATAL_ERROR "Build step for safestring failed: ${ss_result}")
endif()

if(${APPLE})
    # Apply fixes to allow build on MacOS
    #
    # Note that this is only for development, not for testing or deployment.
    execute_process(COMMAND "patch"
        "${INTEL_SAFESTRING_DIR}/safestring-src/CMakeLists.txt"
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/safestring-cmake.patch"
        RESULT_VARIABLE ssc_result
    )
    if(ssc_result)
        message(FATAL_ERROR "Failed to patch safestring CMakeLists")
    endif()

    execute_process(COMMAND "patch"
        "${INTEL_SAFESTRING_DIR}/safestring-src/makefile"
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/safestring-make.patch"
        RESULT_VARIABLE ssc_result
    )
    if(ssc_result)
        message(FATAL_ERROR "Failed to patch safestring Makefile")
    endif()

    # SafeString lib uses redefines memset_s in a standards-incompatible way,
    # which breaks the build. Replace with OS-defined implementation.
    execute_process(COMMAND "patch"
        "${INTEL_SAFESTRING_DIR}/safestring-src/include/safe_mem_lib.h"
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/safestring-memlib.patch"
        RESULT_VARIABLE ssc_result
    )
    if(ssc_result)
        message(FATAL_ERROR "Failed to patch safestring memlib")
    endif()

    execute_process(COMMAND "patch"
        "${INTEL_SAFESTRING_DIR}/safestring-src/safeclib/memset_s.c"
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/safestring-memlib-c.patch"
        RESULT_VARIABLE ssc_result
    )
    if(ssc_result)
        message(FATAL_ERROR "Failed to patch safestring memlib")
    endif()
endif()

execute_process(COMMAND "echo" "Changing safe_str_lib.h file")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/safestring.patch.in" safestring.patch)
execute_process(COMMAND "patch"
                    "${INTEL_SAFESTRING_DIR}/safestring-src/include/safe_str_lib.h"
                    "${CMAKE_CURRENT_BINARY_DIR}/safestring.patch"
                RESULT_VARIABLE ss_result
                OUTPUT_VARIABLE ss_output_var)

if(ss_result)
    message(FATAL_ERROR "Changing safe_str_lib.h failed: ${ss_result} : ${ss_output_var}")
endif()

# Add CMake subdirectories for the safestring-src

# NOTE: the safestring-src is put into the source dir for this CMake file.
# Tthis is so that the source can be referenced for the installation and not
# be in the build directory which is prohibited by CMake
add_subdirectory(${INTEL_SAFESTRING_DIR}/safestring-src
                 ${INTEL_SAFESTRING_DIR}/safestring-build
                 EXCLUDE_FROM_ALL)

# Add the include directories for the safestring source
include_directories(${INTEL_SAFESTRING_DIR}/safestring-src/include)

# Add custom safestring shared object to be compiled. This is required because
# in order to install the library it needs to be included from the CMake that
# is in the source directory and not in the build directory.
add_library(safestring SHARED $<TARGET_OBJECTS:safestring_objlib>)

##
## Add CMake configuration for installing the library including files for other
## projects finding the library using CMake
##

include(GNUInstallDirs)
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/IntelSafeString)

install(TARGETS safestring
    EXPORT intelsafestring-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

set_target_properties(safestring PROPERTIES EXPORT_NAME IntelSafeString)
install(
    DIRECTORY ${INTEL_SAFESTRING_DIR}/safestring-src/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

# Export targets to a script
install(EXPORT intelsafestring-targets
    FILE
        IntelSafeStringTargets.cmake
    DESTINATION
        ${INSTALL_CONFIGDIR}
)

# Create a ConfigVersion.cmake file
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    ${INTEL_SAFESTRING_DIR}/IntelSafeStringConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/IntelSafeStringConfig.cmake.in
    ${INTEL_SAFESTRING_DIR}/IntelSafeStringConfig.cmake
    INSTALL_DESTINATION ${INSTALL_CONFIGDIR})

# Install the config, configversion and custom find modules
install(FILES
    ${INTEL_SAFESTRING_DIR}/IntelSafeStringConfigVersion.cmake
    ${INTEL_SAFESTRING_DIR}/IntelSafeStringConfig.cmake
    DESTINATION ${INSTALL_CONFIGDIR}
)

export(EXPORT intelsafestring-targets
       FILE ${INTEL_SAFESTRING_DIR}/IntelSafeStringTargets.cmake)

# Register package in user's package registry
export(PACKAGE IntelSafeString)

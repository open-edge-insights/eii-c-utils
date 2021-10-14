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

cmake_minimum_required(VERSION 3.12)
project(eii-utils
    VERSION 2.6.0
    LANGUAGES C CXX
    DESCRIPTION "Intel's Edge Insights for Industrial (EII) C/C++ Utility Library"
    HOMEPAGE_URL "https://github.com/open-edge-insights/eii-c-utils")

set(PROJECT_LICENSE "MIT")

# Define CMake options
option(WITH_TESTS    "Compile with unit tests" OFF)

if(NOT DEFINED "CMAKE_BUILD_TYPE" OR "${CMAKE_BUILD_TYPE}" STREQUAL "")
    set(CMAKE_BUILD_TYPE "Release")
endif()

set(EII_C_UTILS_CMAKE "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Set C standard to C11
set(CMAKE_C_STANDARD 11)

# Set CFLAGS
set(CMAKE_C_FLAGS "-fPIE -fPIC -O2 -Wall -pedantic -fstack-protector-strong -D_FORTIFY_SOURCE=2")
set(CMAKE_CXX_FLAGS "-fPIE -fPIC -O2 -Wall -pedantic -fstack-protector-strong -D_FORTIFY_SOURCE=2")

# Set LDFLAGS
set(CMAKE_SHARED_LINKER_FLAGS "-z noexecstack -z relro -z now")

set(CMAKE_CXX_STANDARD 14)

# Include directory for CMake modules
set(CMAKE_MODULE_PATH "${EII_C_UTILS_CMAKE}")

# Find packages
find_package(cJSON REQUIRED)

# Add the IntelSafeString as part of this project
include(cmake/IntelSafeString.cmake)
include(cmake/nlohmann-json.cmake)

# Include header directories
include_directories(include/)

# Get all source files
file(GLOB SOURCES "src/*.c" "src/*.cpp")

# Add target
add_library(eiiutils SHARED ${SOURCES})
target_link_libraries(eiiutils
    PUBLIC
        pthread
        ${CJSON_LIBRARIES}
    PRIVATE
        safestring
        nlohmann_json::nlohmann_json
        nlohmann_json_schema_validator
        ${OpenCV_LIBRARIES}
        ${CMAKE_DL_LIBS})

# If compile in debug mode, set DEBUG flag for C code
if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    target_compile_definitions(eiiutils PRIVATE DEBUG=1)
endif()

# Add unit tests if the option was selected
if(WITH_TESTS)
    add_subdirectory(tests/)
endif()

# Include installation of the library
include(cmake/InstallEIIUtils.cmake)

# Generate packages for the library
# Set base CPack settings and include packaging helper CMake script
set(CPACK_PACKAGE_VENDOR "Intel Corporation")

set(CPACK_PACKAGE_DESCRIPTION "${PROJECT_DESCRIPTION}")

# Debian package specific settings
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Intel Corporation")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libcjson1 (>= 1.7.10)")

# RPM package specific settings
set(CPACK_RPM_PACKAGE_REQUIRES "cjson >= 1.7.14")

# APK specific settings
set(APKBUILD_DEPENDS "cjson")
set(APKBUILD_DEPENDS_DEV "")
set(APKBUILD_DEPENDS_MAKE "cjson-dev")

# Include packaging utility
include(cmake/Package.cmake)

# Export compile commands
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if(EXISTS "${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json")
    EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
        ${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json
    )
endif()

// Copyright (c) 2021 Intel Corporation.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

/**
 * @brief JSON schema validation utility implementations
 */

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <nlohmann/json-schema.hpp>
#include "eii/utils/json_validator.h"
#include "eii/utils/logger.h"

using nlohmann::json;
using nlohmann::json_schema::json_validator;

namespace eii {
namespace utils {

// Prototypes
static std::string read_file(const char* fn);

bool validate_json_buffer_buffer(const char* schema, const char* json_bytes) {
    try {
        // Parse JSON bytes
        auto schema_json = json::parse(schema);
        auto json_data = json::parse(json_bytes);

        // Create json schema validator
        json_validator validator;

        // Set the root schema
        validator.set_root_schema(schema_json);

        // Validate the json data
        validator.validate(json_data);

        // If no exceptions occur, then the JSON data is valid
        return true;
    } catch (const std::exception& ex) {
        LOG_ERROR("JSON schema validation failed: %s", ex.what());
        return false;
    }
}

bool validate_json_file_buffer(
        const char* schema_filename, const char* json_bytes) {
    try {
        std::string schema_str = read_file(schema_filename);
        const char* schema = schema_str.c_str();

        return validate_json_buffer_buffer(schema, json_bytes);
    } catch (const std::exception& ex) {
        LOG_ERROR("JSON schema validation failed: %s", ex.what());
        return false;
    }
}

bool validate_json_file_file(
        const char* schema_filename, const char* json_file) {
    try {
        std::string schema_str = read_file(schema_filename);
        const char* schema = schema_str.c_str();

        std::string json_str = read_file(json_file);
        const char* json_bytes = json_str.c_str();

        return validate_json_buffer_buffer(schema, json_bytes);
    } catch (const std::exception& ex) {
        LOG_ERROR("JSON schema validation failed: %s", ex.what());
        return false;
    }
}

/**
 * Helper method to read in a file into a string.
 *
 * \exception std::runtime_error If reading the file fails.
 *
 * @param fn - Filename of the file to read
 * @return std::string of the file's contents
 */
static std::string read_file(const char* fn) {
    std::ifstream fd(fn);
    std::stringstream ss;
    if (fd.is_open()) {
        ss << fd.rdbuf();
        fd.close();

        return ss.str();
    }
    throw std::runtime_error("Failed to open file");
}

}  // namespace utils
}  // namespace eii

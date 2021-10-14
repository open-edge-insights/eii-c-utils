// Copyright (c) 2020 Intel Corporation.
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
 * @file
 * @brief Utility function for validating a JSON file
 */

#ifndef _EII_UTILS_JSON_VALID_H
#define _EII_UTILS_JSON_VALID_H

namespace eii {
namespace utils {

/**
 * Validate that the json data adheres to the given schema.
 *
 * @param schema     - Raw bytes of the JSON schema
 * @param json_bytes - Raw bytes of the JSON payload
 * @return True if valid, otherwise false
 */
bool validate_json_buffer_buffer(const char* schema, const char* json_bytes);

/**
 * Validate that the json data adheres to the given schema contained in the
 * file pointed to by the schema_filename parameter.
 *
 * @param schema_filename - JSON schema file to read
 * @param json_bytes      - Raw bytes of the JSON payload
 * @return True if valid, otherwise false
 */
bool validate_json_file_buffer(
        const char* schema_filename, const char* json_bytes);

/**
 * Validate that the json data in the JSON file adheres to the given schema
 * contained in the file pointed to by the schema_filename parameter.
 *
 * @param schema_filename - JSON schema file to read
 * @param json_file       - JSON payload file to validate against the schema
 * @return True if valid, otherwise false
 */
bool validate_json_file_file(
        const char* schema_filename, const char* json_file);

}  // utils
}  // eii

#endif // _EII_UTILS_JSON_VALID_H

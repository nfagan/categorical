#pragma once

#include "mex.h"
#include <functional>
#include <string>
#include <vector>
#include <cstdint>
#include <cstdlib>
#include <cstring>

namespace util {
    typedef std::function<void(int, mxArray**, int, const mxArray**)> mex_func_t;
    
    std::string get_string(const mxArray* in_arr, bool* success);
    std::string get_string_with_trap(const mxArray* in_arr, const char* id);
    std::vector<std::string> get_strings(const mxArray* in_arr, const char* id);
    
    template<typename T>
    mxArray* numeric_vector_to_array(const std::vector<T>& in_vec, mxClassID output_kind);
    
    std::vector<uint64_t> numeric_array_to_vector64(const mxArray* in_arr, const char* func_id);
    std::vector<uint32_t> numeric_array_to_vector32(const mxArray* in_arr, const char* func_id);
    
    mxArray* string_vector_to_array(const std::vector<std::string>& in_vec);
    void assign_string_vector_to_array(const std::vector<std::string>& in_vec, 
        mxArray* out_cell, uint64_t start_idx);
    
    void assert_nlhs(int actual, int expected, const char* id);
    void assert_nlhs(int minimum, int maximum, int actual, const char* id);
    void assert_nrhs(int actual, int expected, const char* id);
    void assert_nrhs(int minimum, int maximum, int actual, const char* id);
    void assert_scalar(const mxArray *arr, const char* id, const char* msg);
    void assert_isa(const mxArray *arr, unsigned int class_id, const char* id, const char* msg);
    
    std::string get_error_text_missing_category(const std::string& in_category);
    std::string get_error_text_present_category(const std::string& in_category);
    std::string get_error_text_label_exists();
}

#include "cat_mex_helpers_impl.hpp"
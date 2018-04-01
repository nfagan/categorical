#pragma once

#include "mex.h"
#include <cstddef>
#include <string>

namespace util {
    
    void assert_ndimensions(const mxArray* arr, size_t ndims, const char* id);
    void assert_scalar(const mxArray *arr, const char* id, const char* msg);
    void assert_nrhs(int actual, int expected, const char* id);
    void assert_nrhs(int minimum, int maximum, int actual, const char* id);
    void assert_nlhs(int actual, int expected, const char* id);
    void assert_nlhs(int minimum, int maximum, int actual, const char* id);
    void assert_isa(const mxArray *arr, unsigned int class_id, const char* id, const char* msg);

}
#pragma once

#include "mex.h"
#include "mex_helpers.hpp"
#include <cstdint>
#include <functional>

namespace util {
    using rowop_t = std::function<void(double*, size_t, size_t, 
            double*, size_t, size_t, uint64_t*, size_t)>;
    
    void run(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[], 
            const char* func_id, rowop_t func);
    void validate(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[], 
            const char* func_id);
    
}
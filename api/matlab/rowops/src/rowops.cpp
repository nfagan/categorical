#include "rowops.hpp"
#include <iostream>
#include <cmath>
#include <cstring>

namespace {
    void fill_nan(double* data, size_t rows, size_t cols, size_t crow)
    {
        for (size_t i = 0; i < cols; i++)
        {
            const size_t idx = crow + i * rows;
            data[idx] = std::nan("");
        }
    }
}

void util::run(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[], 
        const char* func_id, util::rowop_t func)
{
    util::validate(nlhs, plhs, nrhs, prhs, func_id);
    
    const mxArray* in_data = prhs[0];
    const mxArray* in_indices = prhs[1];
    
    size_t n_indices = mxGetNumberOfElements(in_indices);
    size_t n_rows = mxGetM(in_data);
    size_t n_cols = mxGetN(in_data);
    
    mxArray* out_data = mxCreateUninitNumericMatrix(n_indices, n_cols, 
            mxDOUBLE_CLASS, mxREAL);
    
    double* in_data_ptr = mxGetPr(in_data);
    double* out_data_ptr = mxGetPr(out_data);
    
    for (size_t i = 0; i < n_indices; i++)
    {
        const mxArray* in_index = mxGetCell(in_indices, i);
        
        //  if empty cell {}, fill row with NaN
        if (in_index == nullptr)
        {
            fill_nan(out_data_ptr, n_indices, n_cols, i);
            continue;
        }
        
        mxClassID index_class = mxGetClassID(in_index);
        
        if (index_class != mxUINT64_CLASS)
        {
            mexErrMsgIdAndTxt(func_id, "Individual indices must be uint64.");
        }
        
        size_t n_index_els = mxGetNumberOfElements(in_index);
        
        //  if empty index [], fill row with NaN
        if (n_index_els == 0)
        {
            fill_nan(out_data_ptr, n_indices, n_cols, i);
            continue;
        }
        
        uint64_t* indices = (uint64_t*) mxGetData(in_index);
        
        if (indices[0] == 0 || indices[n_index_els-1] > n_rows)
        {
            mexErrMsgIdAndTxt(func_id, "Index exceeds matrix dimensions.");
        }
        
        func(in_data_ptr, n_rows, n_cols, out_data_ptr, i, n_indices, indices, n_index_els);
    }
    
    plhs[0] = out_data;
}

void util::validate(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[], const char* func_id)
{
    const char* wrong_indices_msg = "Indices must be a cell array of uint64";
    
    util::assert_nrhs(2, nrhs, func_id);
    util::assert_nlhs(1, nlhs, func_id);
    
    const mxArray* data = prhs[0];
    const mxArray* indices = prhs[1];
    
    util::assert_isa(data, mxDOUBLE_CLASS, func_id, "Data must be double.");
    util::assert_isa(indices, mxCELL_CLASS, func_id, wrong_indices_msg);
    
    size_t n_dims_data = mxGetNumberOfDimensions(data);
    size_t n_dims_indices = mxGetNumberOfDimensions(indices);
    
    util::assert_ndimensions(data, 2, func_id);
    util::assert_ndimensions(indices, 2, func_id);
}
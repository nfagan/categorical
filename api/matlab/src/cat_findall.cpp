#include "cat_api.hpp"
#include <cstring>

namespace
{    
    bool is_class_id(const mxArray* array, const mxClassID id)
    {
        return mxGetClassID(array) == id;
    }
    
    util::categorical::find_all_method get_method(const char* func_id, const mxArray* array)
    {
        char method_str[5];

        if (mxGetString(array, method_str, sizeof(method_str)))
        {
            mexErrMsgIdAndTxt(func_id, "Invalid char method specifier.");
        }
        
        if (std::strcmp("sort", method_str) == 0)
        {
            return util::categorical::find_all_method::sort;    
        } 
        else if (std::strcmp("hash", method_str) == 0)
        {
            return util::categorical::find_all_method::hash;
        }
        else
        {
            mexErrMsgIdAndTxt(func_id, "Unrecognized method specifier.");
            return util::categorical::find_all_method::hash;
        }
    }
}

void util::find_all(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u32;
    using util::u64;
    
    const char* func_id = "categorical:findall";
    
    util::assert_nrhs(3, 5, nrhs, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    std::vector<std::string> categories = util::get_strings(prhs[2], func_id);
    
    const mxArray* maybe_method_specifier = nullptr;
    const mxArray* maybe_indices = nullptr;
    
    bool use_indices = false;
    const u64 index_offset = 1; //  indices start at 1
    std::vector<u64> indices;    
    
    if (nrhs == 4)
    {
        if (is_class_id(prhs[3], mxCHAR_CLASS))
        {
            maybe_method_specifier = prhs[3];
        }
        else
        {
            maybe_indices = prhs[3];
            use_indices = true;
        }
    }
    else if (nrhs == 5)
    {
        use_indices = true;
        maybe_indices = prhs[3];
        
        if (!is_class_id(prhs[4], mxCHAR_CLASS))
        {
            mexErrMsgIdAndTxt(func_id, "Method specifier must be char.");
        }
        
        maybe_method_specifier = prhs[4];
    }
    
    auto method = util::categorical::find_all_method::hash;
    
    if (maybe_method_specifier)
    {
        method = get_method(func_id, maybe_method_specifier);
    }
    
    if (use_indices)
    {
        indices = util::double_or_uint64_array_to_vector64(maybe_indices, func_id);
    }
    
    std::vector<std::vector<u64>> result;
    
    if (use_indices)
    {
        u32 status;
        result = cat->find_all(method, categories, indices, &status, index_offset);
        
        if (status != util::categorical_status::OK)
        {
            if (status == util::categorical_status::OUT_OF_BOUNDS)
            {
                mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
            }
            
            mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
        }
    }
    else
    {
        result = cat->find_all(method, categories, index_offset);
    }
    
    u64 n_combinations = result.size(); 
    mxArray* all_indices = mxCreateCellMatrix(n_combinations, 1);
    
    for (u64 i = 0; i < n_combinations; i++)
    {
        const std::vector<u64>& c_inds = result[i];
        mxArray* indices = util::numeric_vector_to_array(c_inds, mxUINT64_CLASS);
        mxSetCell(all_indices, i, indices);
    }
    
    plhs[0] = all_indices;
}
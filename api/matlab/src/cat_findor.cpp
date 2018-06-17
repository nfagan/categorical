#include "cat_api.hpp"

void util::find_or(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    using util::u32;
    
    const char* func_id = "categorical:findor";
    
    util::assert_nrhs(3, 4, nrhs, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);    
    std::vector<std::string> labels = util::get_strings(prhs[2], func_id);
    
    u64 index_offset = 1; //  indices start at 1
    
    std::vector<u64> result;
    
    if (nrhs == 3)
    {
        result = cat->find_or(labels, index_offset);
    }
    else
    {
        u32 status;
        
        std::vector<u64> indices = util::numeric_array_to_vector64(prhs[3], func_id);
        
        result = cat->find_or(labels, indices, &status, index_offset);
        
        if (status != util::categorical_status::OK)
        {
            if (status == util::categorical_status::OUT_OF_BOUNDS)
            {
                mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
            }
            
            mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
        }
    }
        
    plhs[0] = util::numeric_vector_to_array(result, mxUINT64_CLASS);
}
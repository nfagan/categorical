#include "cat_api.hpp"

void util::keep(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:keep";
  
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<util::u64> indices = util::numeric_array_to_vector64(prhs[2], func_id);
    
    util::u64 index_offset = 1;
    
    util::u32 status = cat->keep(indices, index_offset);
    
    if (status == util::categorical_status::OK)
    {
        return;
    }
    
    if (status == util::categorical_status::OUT_OF_BOUNDS)
    {
        mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
    }
    
    mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
}
#include "cat_api.hpp"

void util::resize(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:keep";
    const char* sz_msg = "Size must be a uint64 scalar.";
  
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::assert_scalar(prhs[2], func_id, sz_msg);
    util::assert_isa(prhs[2], mxUINT64_CLASS, func_id, sz_msg);   
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    util::u64 to_size = (util::u64) mxGetScalar(prhs[2]);
    
    cat->reserve(to_size);
}
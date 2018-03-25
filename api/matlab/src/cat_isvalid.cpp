#include "cat_api.hpp"

void util::is_valid(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:is_valid";
    
    util::assert_nrhs(nrhs, 2, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    bool valid = util::detail::is_valid_ptr<util::categorical>(prhs[1]);
    
    plhs[0] = mxCreateLogicalScalar(valid);
}
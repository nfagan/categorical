#include "cat_api.hpp"

void util::copy(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:copy";
  
    util::assert_nrhs(nrhs, 2, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat_a = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    plhs[0] = util::detail::ptr_to_mat<util::categorical>(new util::categorical(*cat_a));
}
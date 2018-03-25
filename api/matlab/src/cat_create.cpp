#include "cat_api.hpp"

void util::create(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:create";
  
    util::assert_nrhs(nrhs, 1, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    plhs[0] = util::detail::ptr_to_mat<util::categorical>(new util::categorical());
}
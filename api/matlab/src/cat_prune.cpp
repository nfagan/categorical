#include "cat_api.hpp"

void util::prune(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:prune";
  
    util::assert_nrhs(nrhs, 2, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    plhs[0] = mxCreateUninitNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    
    u64* n_pruned = (u64*) mxGetData(plhs[0]);
    
    n_pruned[0] = cat->prune();
}
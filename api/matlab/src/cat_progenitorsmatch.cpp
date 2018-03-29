#include "cat_api.hpp"

void util::progenitors_match(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:progenitorsmatch";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat_a = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    util::categorical* cat_b = util::detail::mat_to_ptr<util::categorical>(prhs[2]);
    
#ifdef CAT_USE_PROGENITOR_IDS    
    plhs[0] = mxCreateLogicalScalar(cat_a->progenitors_match(*cat_b));
#else
    plhs[0] = mxCreateLogicalScalar(false);
#endif
}
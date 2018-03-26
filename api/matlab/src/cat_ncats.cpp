#include "cat_api.hpp"

void util::n_categories(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:ncats";
    
    util::assert_nrhs(nrhs, 2, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);    
    
    plhs[0] = mxCreateUninitNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    
    u64* data = (u64*) mxGetData(plhs[0]);
    
    data[0] = cat->n_categories();
}
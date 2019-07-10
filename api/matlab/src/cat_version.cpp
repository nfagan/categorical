#include "cat_api.hpp"
#include "cat_version.hpp"

void util::get_version(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    const char* func_id = "categorical:version";
    
    util::assert_nrhs(nrhs, 1, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    plhs[0] = mxCreateString(util::CATEGORICAL_VERSION_ID);
}
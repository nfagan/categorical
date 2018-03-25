#include "cat_api.hpp"

void util::destroy(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    util::assert_nrhs(nrhs, 2, "categorical:destroy");
    util::assert_nlhs(nlhs, 0, "categorical:destroy");
    
    if (util::detail::is_valid_ptr<util::categorical>(prhs[1]))
    {
        util::detail::destroy<util::categorical>(prhs[1]);
    }
}
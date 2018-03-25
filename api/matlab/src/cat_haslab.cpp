#include "cat_api.hpp"

void util::has_label(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:haslab";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> labs = util::get_strings(prhs[2], func_id);
    
    util::u64 n_labs = labs.size();
    
    mxArray* tfs = mxCreateLogicalMatrix(n_labs, 1);
    bool* logicals = (bool*) mxGetLogicals(tfs);
    
    for (util::u64 i = 0; i < n_labs; i++)
    {
        logicals[i] = cat->has_label(labs[i]);
    }
    
    plhs[0] = tfs;
}
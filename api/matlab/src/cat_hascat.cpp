#include "cat_api.hpp"

void util::has_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:hascat";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> cats = util::get_strings(prhs[2], func_id);
    
    util::u64 n_labs = cats.size();
    
    mxArray* tfs = mxCreateLogicalMatrix(n_labs, 1);
    bool* logicals = (bool*) mxGetLogicals(tfs);
    
    for (util::u64 i = 0; i < n_labs; i++)
    {
        logicals[i] = cat->has_category(cats[i]);
    }
    
    plhs[0] = tfs;
}
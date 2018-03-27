#include "cat_api.hpp"

void util::count(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:count";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> labs = util::get_strings(prhs[2], func_id);
    
    util::u64 n_labs = labs.size();
    
    std::vector<util::u64> res(n_labs);
    
    for (util::u64 i = 0; i < n_labs; i++)
    {
        res[i] = cat->count(labs[i]);
    }
    
    plhs[0] = util::numeric_vector_to_array(res, mxUINT64_CLASS);
}
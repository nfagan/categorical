#include "cat_api.hpp"

void util::in_categories(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    const char* func_id = "categorical:incats";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> cats = util::get_strings(prhs[2], func_id);
    
    bool exists;
    
    std::vector<std::string> in_cats = cat->in_categories(cats, &exists);
    
    if (!exists)
    {
        mexErrMsgIdAndTxt(func_id, "At least one category does not exist.");
    }
    
    plhs[0] = util::string_vector_to_array(in_cats);
}
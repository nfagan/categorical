#include "cat_api.hpp"

void util::in_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    const char* func_id = "categorical:incat";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    bool str_success;
    bool cat_exists;
    
    std::string category = util::get_string(prhs[2], &str_success);
    
    if (!str_success)
    {
        mexErrMsgIdAndTxt(func_id, "String copy failed.");
    }
    
    std::vector<std::string> in_cat = cat->in_category(category, &cat_exists);
    
    if (!cat_exists)
    {
        std::string msg = util::get_error_text_missing_category(category);
        mexErrMsgIdAndTxt(func_id, msg.c_str());
    }
    
    plhs[0] = util::string_vector_to_array(in_cat);
}
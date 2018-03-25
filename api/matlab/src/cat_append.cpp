#include "cat_api.hpp"

void util::append(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u32;
    
    const char* func_id = "categorical:append";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat_a = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    util::categorical* cat_b = util::detail::mat_to_ptr<util::categorical>(prhs[2]);
    
    u32 status = cat_a->append(*cat_b);
    
    if (status == util::categorical_status::OK)
    {
        return;
    }
    
    if (status == util::categorical_status::CATEGORIES_DO_NOT_MATCH)
    {
        mexErrMsgIdAndTxt(func_id, "Categories do not match.");
    }
    
    if (status == util::categorical_status::CAT_OVERFLOW)
    {
        mexErrMsgIdAndTxt(func_id, "Append operation would result in overflow.");
    }
    
    if (status == util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY)
    {
        mexErrMsgIdAndTxt(func_id, util::get_error_text_label_exists().c_str());
    }
    
    mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
}
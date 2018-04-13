#include "cat_api.hpp"

void util::merge(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u32;
    
    const char* func_id = "categorical:merge";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat_a = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    util::categorical* cat_b = util::detail::mat_to_ptr<util::categorical>(prhs[2]);
    
    u32 status = cat_a->merge(*cat_b);
    
    if (status == util::categorical_status::OK)
    {
        return;
    }
    
    if (status == util::categorical_status::INCOMPATIBLE_SIZES)
    {
        mexErrMsgIdAndTxt(func_id, "Sizes of arrays are incompatible.");
    }
    
    if (status == util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY)
    {
        mexErrMsgIdAndTxt(func_id, util::get_error_text_label_exists().c_str());
    }
    
    if (status == util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY)
    {
        const char* msg = "Labels cannot contain the collapsed expression of a different category.";
        mexErrMsgIdAndTxt(func_id, msg);
    }
    
    mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
}
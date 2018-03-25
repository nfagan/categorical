#include "cat_api.hpp"

void util::set_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:setcat";
    
    util::assert_nrhs(nrhs, 4, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);    
    std::string cat_name = util::get_string_with_trap(prhs[2], func_id);
    std::vector<std::string> full_cat = util::get_strings(prhs[3], func_id);
    
    util::u32 status = cat->set_category(cat_name, full_cat);
    
    if (status == util::categorical_status::OK)
    {
        return;
    }
    
    if (status == util::categorical_status::CATEGORY_DOES_NOT_EXIST)
    {
        std::string msg = util::get_error_text_missing_category(cat_name);
        mexErrMsgIdAndTxt(func_id, msg.c_str());
    }
    
    if (status == util::categorical_status::WRONG_CATEGORY_SIZE)
    {
        mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
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
    
    mexErrMsgIdAndTxt(func_id, "An unknown error ocurred.");
}
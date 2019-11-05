#include "cat_api.hpp"

void util::set_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    using util::u32;
    using namespace util::categorical_status;
    
    const char* func_id = "categorical:setcat";
    
    util::assert_nrhs(4, 5, nrhs, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    const bool use_indices = nrhs == 5;
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);    
    std::string cat_name = util::get_string_with_trap(prhs[2], func_id);
    std::vector<std::string> part_cat = util::get_strings(prhs[3], func_id);
    
    u32 status;
    
    if (use_indices)
    {
        const std::vector<u64> at_indices = util::numeric_array_to_vector64(prhs[4], func_id);
        const u64 index_offset = 1;
        
        status = cat->set_category(cat_name, part_cat, at_indices, index_offset);
    }
    else
    {
        status = cat->set_category(cat_name, part_cat);
    }
    
    if (status == util::categorical_status::OK)
    {
        return;
    }
    
    if (status == CATEGORY_DOES_NOT_EXIST)
    {
        std::string msg = util::get_error_text_missing_category(cat_name);
        mexErrMsgIdAndTxt(func_id, msg.c_str());
    }
    
    if (status == WRONG_CATEGORY_SIZE || status == WRONG_INDEX_SIZE ||
            status == CAT_OVERFLOW || status == OUT_OF_BOUNDS)
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
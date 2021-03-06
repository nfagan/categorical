#include "cat_api.hpp"
#include <algorithm>

void util::assign(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:assign";
    
    util::assert_nrhs(4, 5, nrhs, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat_a = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    const util::categorical* cat_b = util::detail::mat_to_ptr<util::categorical>(prhs[2]);
    
    const std::vector<util::u64> at_indices = util::numeric_array_to_vector64(prhs[3], func_id);
    const util::u64 index_offset = 1;
    
    util::u32 status;
    
    if (nrhs == 4)
    {
        status = cat_a->assign(*cat_b, at_indices, index_offset);
    } 
    else
    {
        const std::vector<util::u64> from_indices = util::numeric_array_to_vector64(prhs[4], func_id);
        status = cat_a->assign(*cat_b, at_indices, from_indices, index_offset);
    }
    
    if (status == util::categorical_status::OK)
    {
        return;
    }
    
    if (status == util::categorical_status::CATEGORIES_DO_NOT_MATCH)
    {
        mexErrMsgIdAndTxt(func_id, "Categories do not match.");
    }
    
    if (status == util::categorical_status::WRONG_INDEX_SIZE)
    {
        mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
    }
    
    if (status == util::categorical_status::OUT_OF_BOUNDS)
    {
        mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
    }
    
    if (status == util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY)
    {
        mexErrMsgIdAndTxt(func_id, util::get_error_text_label_exists().c_str());
    }
    
    mexErrMsgIdAndTxt(func_id, "An unknown error ocurred.");
}
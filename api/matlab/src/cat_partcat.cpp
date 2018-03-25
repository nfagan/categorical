#include "cat_api.hpp"

void util::partial_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
  
    using std::vector;
    using std::string;
  
    const char* func_id = "categorical:partcat";
    
    util::assert_nrhs(nrhs, 4, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    string category = util::get_string_with_trap(prhs[2], func_id);
    
    vector<util::u64> at_indices = util::numeric_array_to_vector64(prhs[3], func_id);
    
    bool cat_exists;
    util::s64 index_offset = -1;
    util::u32 status;
    
    vector<string> part_cat = cat->partial_category(category, at_indices, &status, index_offset);
    
    if (status == util::categorical_status::OK)
    {
        plhs[0] = util::string_vector_to_array(part_cat);
        return;
    }
    
    if (status == util::categorical_status::CATEGORY_DOES_NOT_EXIST)
    {
        string msg = util::get_error_text_missing_category(category);
        mexErrMsgIdAndTxt(func_id, msg.c_str());
    }
    
    if (status == util::categorical_status::OUT_OF_BOUNDS)
    {
        mexErrMsgIdAndTxt(func_id, "Index exceeds Categorical dimensions.");
    }
    
    mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
}
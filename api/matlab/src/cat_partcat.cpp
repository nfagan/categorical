#include "cat_api.hpp"

void util::partial_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using std::vector;
    using std::string;
  
    const char* func_id = "categorical:partcat";
    
    util::assert_nrhs(nrhs, 4, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    vector<string> categories = util::get_strings(prhs[2], func_id);
    
    vector<util::u64> at_indices = util::numeric_array_to_vector64(prhs[3], func_id);
    
    u64 n_cats = categories.size();
    u64 n_indices = at_indices.size();
    
    mxArray* strs = mxCreateCellMatrix(n_cats * n_indices, 1);
    u64 assign_at = 0;
    
    for (u64 i = 0; i < n_cats; i++)
    {
        bool cat_exists;
        util::s64 index_offset = -1;
        util::u32 status;
        
        const std::string& c_cat = categories[i];

        vector<string> part_cat = cat->partial_category(c_cat, at_indices, &status, index_offset);

        if (status == util::categorical_status::OK)
        {
            util::assign_string_vector_to_array(part_cat, strs, assign_at);
            assign_at += part_cat.size();
            continue;
        }
        
        //
        //  otherwise, we have to cleanup
        //
        
        for (u64 j = 0; j < assign_at; j++)
        {
            mxDestroyArray(mxGetCell(strs, j));
        }

        mxDestroyArray(strs);

        if (status == util::categorical_status::CATEGORY_DOES_NOT_EXIST)
        {
            string msg = util::get_error_text_missing_category(c_cat);
            mexErrMsgIdAndTxt(func_id, msg.c_str());
        }

        if (status == util::categorical_status::OUT_OF_BOUNDS)
        {
            mexErrMsgIdAndTxt(func_id, "Index exceeds Categorical dimensions.");
        }

        mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
    }
    
    plhs[0] = strs;
}
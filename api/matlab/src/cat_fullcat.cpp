#include "cat_api.hpp"

void util::full_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    using util::u64;
    
    const char* func_id = "categorical:fullcat";
    
    util::assert_nrhs(3, 4, nrhs, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    const bool use_indices = nrhs == 4;
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    const std::vector<std::string> categories = util::get_strings(prhs[2], func_id);
    std::vector<u64> indices;
    const u64 index_offset = 1;
    
    if (use_indices)
    {
        indices = util::numeric_array_to_vector64(prhs[3], func_id);
    }
        
    const u64 num_cats = categories.size();
    const u64 num_rows = use_indices ? indices.size() : cat->size();
    
    mxArray* strs = mxCreateCellMatrix(num_cats * num_rows, 1);
    u64 assign_at = 0;
    
    for (u64 i = 0; i < num_cats; i++)
    {
        u32 status = util::categorical_status::OK;
        const std::string& c_cat = categories[i];
        
        std::vector<std::string> full_cat; 
        
        if (use_indices)
        {
            full_cat = cat->partial_category(c_cat, indices, &status, index_offset);
        }
        else
        {
            bool cat_exists;
            full_cat = cat->full_category(c_cat, &cat_exists);
            
            if (!cat_exists)
            {
                status = util::categorical_status::CATEGORY_DOES_NOT_EXIST;
            }
        }
        
        if (status == util::categorical_status::OK)
        {
            util::assign_string_vector_to_array(full_cat, strs, assign_at);
            assign_at += full_cat.size();
            continue;
        }
        
        //  Delete created string arrays.
        mxDestroyArray(strs);

        if (status == util::categorical_status::CATEGORY_DOES_NOT_EXIST)
        {
            std::string msg = util::get_error_text_missing_category(c_cat);
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
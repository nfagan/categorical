#include "cat_api.hpp"

void util::append_one(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u32;
    using util::u64;
    
    const char* func_id = "categorical:append1";
    
    util::assert_nrhs(3, 5, nrhs, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat_a = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    util::categorical* cat_b = util::detail::mat_to_ptr<util::categorical>(prhs[2]);
    
    u32 status;
    
    if (nrhs == 3)
    {
        status = cat_a->append_one(*cat_b);
    }
    else
    {
        u64 index_offset = 1;
        
        std::vector<u64> indices = util::numeric_array_to_vector64(prhs[3], func_id);
        
        if (nrhs == 4)
        {
            status = cat_a->append_one(*cat_b, indices, index_offset);
        }
        else
        {
            const char* msg = "Repetitions must be a uin64 scalar.";
            u64 repetitions = util::get_scalar_with_trap<u64>(prhs[4], mxUINT64_CLASS, func_id, msg);
            
            if (repetitions == 0)
            {
                // in matlab, 0 repetition should not mutate object.
                status = util::categorical_status::OK;
            }
            else
            {
                status = cat_a->append_one(*cat_b, indices, index_offset, repetitions-1);
            }
        }
    }
    
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
    
    if (status == util::categorical_status::OUT_OF_BOUNDS)
    {
        mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
    }
    
    mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
}
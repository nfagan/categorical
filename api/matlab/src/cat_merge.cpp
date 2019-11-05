#include "cat_api.hpp"

namespace
{
    util::u32 merge_function_id(const mxArray* array, const char* func_id)
    {
        const char* msg = "Merge function id must be a uint32 scalar.";
        const util::u32 id = util::get_scalar_with_trap<util::u32>(array, mxUINT32_CLASS, func_id, msg);
        
        switch (id)
        {
            case 0:
            case 1:
                return id;
            default:
                mexErrMsgIdAndTxt(func_id, "Unrecognized merge function id.");
                //  Unreachable.
                return 0;
        }
    }
}

void util::merge(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u32;
    
    const char* func_id = "categorical:merge";
    
    util::assert_nrhs(nrhs, 4, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    const u32 merge_func_id = merge_function_id(prhs[1], func_id);
            
    util::categorical* cat_a = util::detail::mat_to_ptr<util::categorical>(prhs[2]);
    util::categorical* cat_b = util::detail::mat_to_ptr<util::categorical>(prhs[3]);
    
    u32 status;
    
    switch (merge_func_id)
    {
        case 0:
            status = cat_a->merge(*cat_b);
            break;
        case 1:
            status = cat_a->merge_new(*cat_b);
            break;
        default:
            mexErrMsgIdAndTxt(func_id, "Unrecognized merge function id.");
            break;
    }
    
    switch (status)
    {
        case util::categorical_status::OK:
            return;
        case util::categorical_status::INCOMPATIBLE_SIZES:
            mexErrMsgIdAndTxt(func_id, "Sizes of arrays are incompatible.");
            break;
        case util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY:
            mexErrMsgIdAndTxt(func_id, util::get_error_text_label_exists().c_str());
            break;
        case util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY: 
        {
            const char* msg = "Labels cannot contain the collapsed expression of a different category.";
            mexErrMsgIdAndTxt(func_id, msg);
            break;
        }
        default:
            mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
    }    
}
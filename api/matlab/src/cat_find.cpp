#include "cat_api.hpp"

namespace
{
    util::u32 find_function_id(const mxArray* array, const char* func_id)
    {
        const char* msg = "Find function id must be a uint32 scalar.";
        const util::u32 id = util::get_scalar_with_trap<util::u32>(array, mxUINT32_CLASS, func_id, msg);
        
        switch (id)
        {
            case 0:
            case 1:
            case 2:
            case 3:
                return id;
            default:
                mexErrMsgIdAndTxt(func_id, "Unrecognized find function id.");
                //  Unreachable.
                return 0;
        }
    }
}

void util::find(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    using util::u32;
    
    const char* func_id = "categorical:find";
    
    util::assert_nrhs(4, 5, nrhs, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    const util::u32 find_func_id = find_function_id(prhs[1], func_id);
    const util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[2]);
    const std::vector<std::string> labels = util::get_strings(prhs[3], func_id);
    
    const u64 index_offset = 1;
    
    std::vector<u64> result;
    
    if (nrhs == 4)
    {
        switch (find_func_id)
        {
            case 0:
                result = cat->find(labels, index_offset);
                break;
            case 1:
                result = cat->find_not(labels, index_offset);
                break;
            case 2:
                result = cat->find_or(labels, index_offset);
                break;
            case 3:
                result = cat->find_none(labels, index_offset);
                break;
            default:
                mexErrMsgIdAndTxt(func_id, "Unrecognized find function id.");
                break;
        }
    }
    else
    {
        u32 status;
        const std::vector<u64> indices = util::numeric_array_to_vector64(prhs[4], func_id);
        
        switch (find_func_id)
        {
            case 0:
                result = cat->find(labels, indices, &status, index_offset);
                break;
            case 1:
                result = cat->find_not(labels, indices, &status, index_offset);
                break;
            case 2:
                result = cat->find_or(labels, indices, &status, index_offset);
                break;
            case 3:
                result = cat->find_none(labels, indices, &status, index_offset);
                break;
            default:
                mexErrMsgIdAndTxt(func_id, "Unrecognized find function id.");
                break;
        }
        
        if (status != util::categorical_status::OK)
        {
            if (status == util::categorical_status::OUT_OF_BOUNDS)
            {
                mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
            }
            
            mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
        }
    }
        
    plhs[0] = util::numeric_vector_to_array(result, mxUINT64_CLASS);
}
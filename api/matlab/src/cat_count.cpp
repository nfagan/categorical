#include "cat_api.hpp"

void util::count(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:count";
    
    util::assert_nrhs(3, 4, nrhs, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> labs = util::get_strings(prhs[2], func_id);
    
    util::u64 n_labs = labs.size();
    
    std::vector<util::u64> res(n_labs);
    
    if (nrhs == 3)
    {
        for (util::u64 i = 0; i < n_labs; i++)
        {
            res[i] = cat->count(labs[i]);
        }
    }
    else
    {
        util::u32 status;
        const u64 index_offset = 1;
        std::vector<u64> indices = util::numeric_array_to_vector64(prhs[3], func_id);
        
        for (util::u64 i = 0; i < n_labs; i++)
        {
            res[i] = cat->count(labs[i], indices, &status, index_offset);
            
            if (status == util::categorical_status::OK)
            {
                continue;
            }
            
            if (status == util::categorical_status::OUT_OF_BOUNDS)
            {
                mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
            }
            
            mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
        }
    }
    
    plhs[0] = util::numeric_vector_to_array(res, mxUINT64_CLASS);
}
#include "cat_api.hpp"

void util::keep_each(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:keepeach";
    
    util::assert_nrhs(3, 4, nrhs, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);    
    std::vector<std::string> categories = util::get_strings(prhs[2], func_id);
    
    u64 index_offset = 1; //  indices start at 1
    
    std::vector<std::vector<u64>> result;
    
    if (nrhs == 3)
    {
        result = cat->keep_each(categories, index_offset);
    }
    else
    {
        u32 status;
        
        std::vector<u64> indices = util::numeric_array_to_vector64(prhs[3], func_id);
        
        result = cat->keep_each(categories, indices, &status, index_offset);
        
        if (status != util::categorical_status::OK)
        {
            if (status == util::categorical_status::OUT_OF_BOUNDS)
            {
                mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
            }
            
            mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
        }
    }
    
    u64 n_combinations = result.size(); 
    
    mxArray* all_indices = mxCreateCellMatrix(n_combinations, 1);
    
    for (u64 i = 0; i < n_combinations; i++)
    {
        const std::vector<u64>& c_inds = result[i];
        
        mxArray* indices = util::numeric_vector_to_array(c_inds, mxUINT64_CLASS);
        
        mxSetCell(all_indices, i, indices);
    }
    
    plhs[0] = all_indices;
}
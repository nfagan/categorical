#include "cat_api.hpp"

void util::is_uniform_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:isuncat";
    
    util::assert_nrhs(3, 4, nrhs, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> cats = util::get_strings(prhs[2], func_id);
    util::u64 n_cats = cats.size();
    
    mxArray* tfs = mxCreateLogicalMatrix(n_cats, 1);
    bool* logicals = (bool*) mxGetLogicals(tfs);
    
    if (nrhs == 3)
    {
        bool exist;
        
        for (util::u64 i = 0; i < n_cats; i++)
        {            
            logicals[i] = cat->is_uniform_category(cats[i], &exist);
            
            if (!exist)
            {
                mxDestroyArray(tfs);
                std::string msg = util::get_error_text_missing_category(cats[i]);
                mexErrMsgIdAndTxt(func_id, msg.c_str());
            }
        }
    }
    else
    {
        u32 status;
        
        std::vector<u64> indices = util::numeric_array_to_vector64(prhs[3], func_id);
        const u64 index_offset = 1;
        
        for (util::u64 i = 0; i < n_cats; i++)
        {            
            logicals[i] = cat->is_uniform_category(cats[i], indices, &status, index_offset);
            
            if (status != util::categorical_status::OK)
            {
                mxDestroyArray(tfs);
                
                if (status == util::categorical_status::CATEGORY_DOES_NOT_EXIST)
                {
                    std::string msg = util::get_error_text_missing_category(cats[i]);
                    mexErrMsgIdAndTxt(func_id, msg.c_str());
                }
                
                if (status == util::categorical_status::OUT_OF_BOUNDS)
                {
                    mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
                }
                
                mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
            }
        }
    }
    
    plhs[0] = tfs;
}
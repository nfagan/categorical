#include "cat_api.hpp"

void util::full_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    using util::u64;
    
    const char* func_id = "categorical:fullcat";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> categories = util::get_strings(prhs[2], func_id);
    
    u64 n_cats = categories.size();
    
    mxArray* strs = mxCreateCellMatrix(n_cats * cat->size(), 1);
    u64 assign_at = 0;
    
    for (u64 i = 0; i < n_cats; i++)
    {
        bool cat_exists;
        
        const std::string& c_cat = categories[i];
        
        std::vector<std::string> full_cat = cat->full_category(c_cat, &cat_exists);
        
        //  cleanup created arrays
        if (!cat_exists)
        {            
            mxDestroyArray(strs);
            std::string msg = util::get_error_text_missing_category(c_cat);
            mexErrMsgIdAndTxt(func_id, msg.c_str());
        }
        
        util::assign_string_vector_to_array(full_cat, strs, assign_at);
        
        assign_at += full_cat.size();
                
    }
    
    plhs[0] = strs;
}
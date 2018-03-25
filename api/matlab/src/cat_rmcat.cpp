#include "cat_api.hpp"

void util::remove_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:rmcat";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]); 
    
    const mxArray* cat_or_cats = prhs[2];
    mxClassID id_cats = mxGetClassID(cat_or_cats);
    
    if (id_cats == mxCHAR_CLASS)
    {
        std::string cat_name = util::get_string_with_trap(cat_or_cats, func_id);
        
        bool exists;
        
        cat->remove_category(cat_name, &exists);
        
        if (!exists)
        {
            std::string msg = util::get_error_text_missing_category(cat_name);
            mexErrMsgIdAndTxt(func_id, msg.c_str());
        }
        
        return;
    }
    
    //  input is cell array of strings
    
    std::vector<std::string> cat_names = util::get_strings(cat_or_cats, func_id);

    util::u64 sz = cat_names.size();

    for (util::u64 i = 0; i < sz; i++)
    {   
        const std::string& cat_name = cat_names[i];
        
        if (!cat->has_category(cat_name))
        {
            std::string msg = util::get_error_text_missing_category(cat_name);
            mexErrMsgIdAndTxt(func_id, msg.c_str());
        }
    }
    
    for (util::u64 i = 0; i < sz; i++)
    {
        bool dummy;
        cat->remove_category(cat_names[i], &dummy);
    }
}
#include "cat_api.hpp"

namespace impl {
    void require_cat(util::categorical* cat, const std::string& cat_name, const char* func_id)
    {
        if (cat_name == ":")
        {
            mexErrMsgIdAndTxt(func_id, "Invalid category name ':'.");
        }
        
        util::u32 status = cat->require_category(cat_name);
        
        if (status == util::categorical_status::OK)
        {
            return;
        }
        
        if (status == util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY)
        {
            std::string m1 = "Cannot add category '";
            std::string m2 = "' because the collapsed expression for this category ";
            std::string m3 = "already exists in a different category.";
            mexErrMsgIdAndTxt(func_id, (m1 + cat_name + m2 + m3).c_str());
        }
        
        mexErrMsgIdAndTxt(func_id, "An unknown error ocurred.");
    }
}

void util::require_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:requirecat";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]); 
    
    const mxArray* cat_or_cats = prhs[2];
    mxClassID id_cats = mxGetClassID(cat_or_cats);
    
    if (id_cats == mxCHAR_CLASS)
    {
        std::string cat_name = util::get_string_with_trap(cat_or_cats, func_id);
        
        impl::require_cat(cat, cat_name, func_id);
        
        return;
    }
    
    //  input is cell array of strings
    
    std::vector<std::string> cat_names = util::get_strings(cat_or_cats, func_id);

    util::u64 sz = cat_names.size();

    for (util::u64 i = 0; i < sz; i++)
    {
        impl::require_cat(cat, cat_names[i], func_id);
    }
}
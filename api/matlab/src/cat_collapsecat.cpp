#include "cat_api.hpp"

void util::collapse_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:collapsecat";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]); 
    
    const mxArray* cat_or_cats = prhs[2];
    mxClassID id_cats = mxGetClassID(cat_or_cats);
    
    if (id_cats == mxCHAR_CLASS)
    {
        std::string cat_name = util::get_string_with_trap(cat_or_cats, func_id);
        
        cat->collapse_category(cat_name);
        
        return;
    }
    
    //  input is cell array of strings
    
    std::vector<std::string> cat_names = util::get_strings(cat_or_cats, func_id);

    util::u64 sz = cat_names.size();

    for (util::u64 i = 0; i < sz; i++)
    {
        cat->collapse_category(cat_names[i]);
    }
}
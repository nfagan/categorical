#include "cat_api.hpp"

void util::which_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    using util::u64;
    
    const char* func_id = "categorical:whichcat";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> labs = util::get_strings(prhs[2], func_id);
    std::vector<std::string> res;
    
    bool exists;
    u64 n_labs = labs.size();
    
    for (u64 i = 0; i < n_labs; i++)
    {
        const std::string& lab = labs[i];
        
        res.push_back(cat->which_category(lab, &exists));
        
        if (!exists)
        {
            mexErrMsgIdAndTxt(func_id, util::get_error_text_missing_label(lab).c_str());
        }
    }
    
    plhs[0] = util::string_vector_to_array(res);
}
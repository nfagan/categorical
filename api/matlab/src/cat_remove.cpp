#include "cat_api.hpp"

void util::remove_labels(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    const char* func_id = "categorical:remove";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> labs = util::get_strings(prhs[2], func_id);
    
    cat->remove(labs);
}
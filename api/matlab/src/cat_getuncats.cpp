#include "cat_api.hpp"

void util::get_uniform_categories(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    const char* func_id = "categorical:getuncats";
    
    util::assert_nrhs(nrhs, 2, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);    
    
    plhs[0] = util::string_vector_to_array(cat->get_uniform_categories());
}
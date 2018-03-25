#include "cat_api.hpp"

void util::find(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:find";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);    
    std::vector<std::string> labels = util::get_strings(prhs[2], func_id);
    
    u64 index_offset = 1; //  indices start at 1
    
    std::vector<u64> result = cat->find(labels, index_offset);
        
    plhs[0] = util::numeric_vector_to_array(result, mxUINT64_CLASS);
}
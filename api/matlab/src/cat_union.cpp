#include "cat_api.hpp"

void util::make_set_union(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using namespace util;
    using std::vector;
    
    const char* func_id = "categorical:union";
    assert_nlhs(nlhs, 1, func_id);
    
    if (nrhs < 3)
    {
        mexErrMsgIdAndTxt(func_id, "Not enough input arguments.");
    }
    
    const categorical* a = detail::mat_to_ptr<util::categorical>(prhs[1]);
    const categorical* b = detail::mat_to_ptr<util::categorical>(prhs[2]);
    
    categorical tmp;
    u32 status = categorical_status::OK;
    
    if (nrhs == 3)
    {
        tmp = set_union{*a, *b}(&status);
    }
    else if (nrhs == 4)
    {
        const std::vector<std::string> categories = get_strings(prhs[3], func_id);
        tmp = set_union{*a, *b}(&status);
    }
    else if (nrhs == 5)
    {
        const std::vector<u64> mask_a = double_or_uint64_array_to_vector64(prhs[3], func_id);
        const std::vector<u64> mask_b = double_or_uint64_array_to_vector64(prhs[4], func_id);
        const u64 index_offset = 1;
        
        tmp = set_union{*a, *b}(mask_a, mask_b, &status, index_offset);
    }
    else if (nrhs == 6)
    {
        const std::vector<std::string> categories = get_strings(prhs[3], func_id);
        const std::vector<u64> mask_a = double_or_uint64_array_to_vector64(prhs[4], func_id);
        const std::vector<u64> mask_b = double_or_uint64_array_to_vector64(prhs[5], func_id);
        const u64 index_offset = 1;
        
//         tmp = categorical::set_union(*a, *b, categories, mask_a, mask_b, &status, index_offset);
        tmp = set_union{*a, *b}(mask_a, mask_b, &status, index_offset);
    }
    else
    {
        mexErrMsgIdAndTxt(func_id, "Expected 2, 3, 4, or 5 inputs.");
    }
    
    if (status != categorical_status::OK)
    {
        mexErrMsgIdAndTxt(func_id, "An error occurred.");
    }
        
    categorical* cat = new categorical(std::move(tmp));
    plhs[0] = detail::ptr_to_mat<categorical>(cat);
}
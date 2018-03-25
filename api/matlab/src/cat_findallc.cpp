#include "cat_api.hpp"

void util::find_allc(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    
    const char* func_id = "categorical:findallc";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 2, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    std::vector<std::string> categories = util::get_strings(prhs[2], func_id);
    
    u64 index_offset = 1; //  indices start at 1.
    
    util::combinations_t result = cat->find_allc(categories, index_offset);
    
    u64 n_combinations = result.indices.size(); 
    u64 n_labels = result.combinations.size();
    
    mxArray* all_indices = mxCreateCellMatrix(n_combinations, 1);
    mxArray* all_combs = mxCreateCellMatrix(n_labels, 1);
    
    for (u64 i = 0; i < n_combinations; i++)
    {
        const std::vector<u64>& c_inds = result.indices[i];
        
        mxArray* indices = util::numeric_vector_to_array(c_inds, mxUINT64_CLASS);
        
        mxSetCell(all_indices, i, indices);
    }
    
    for (u64 i = 0; i < n_labels; i++)
    {
        mxArray* str = mxCreateString(result.combinations[i].c_str());
        mxSetCell(all_combs, i, str);
    }
    
    plhs[0] = all_indices;
    plhs[1] = all_combs;
}
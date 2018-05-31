#include "cat_api.hpp"

void util::remove_labels(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    const char* func_id = "categorical:remove";
    
    util::assert_nrhs(nrhs, 3, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> labs = util::get_strings(prhs[2], func_id);
    
    const util::u64 index_offset = 1;
    
    std::vector<util::u64> kept_inds = cat->remove(labs);
    
    util::u64 n_inds = kept_inds.size();
    util::u64* data = kept_inds.data();
    
    for (util::u64 i = 0; i < n_inds; i++)
    {
        //  make output indices 1-based.
        data[i]++;
    }
    
    plhs[0] = util::numeric_vector_to_array(kept_inds, mxUINT64_CLASS);
}
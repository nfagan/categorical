#include "cat_api.hpp"

void util::to_numeric_matrix(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    using util::u32;
    using std::vector;
    
    const char* func_id = "categorical:numcat";
    
    util::assert_nrhs(nrhs, 2, func_id);
    util::assert_nlhs(nlhs, 3, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    util::labels_t labs = cat->get_labels_and_ids();
    vector<const vector<u32>*> all_ids = cat->get_label_mat();
    
    util::u64 n_cats = all_ids.size();
    util::u64 sz = cat->size();
    
    mxArray* mat = mxCreateUninitNumericMatrix(sz, n_cats, mxUINT32_CLASS, mxREAL);
    
    u32* data = (u32*) mxGetData(mat);
    
    for (u64 i = 0; i < n_cats; i++)
    {
        const vector<u32>* col = all_ids[i];
        const u32* src = col->data();
        
        std::memcpy(data + i * sz, src, sz * sizeof(u32));
    }
    
    plhs[0] = mat;
    plhs[1] = util::string_vector_to_array(labs.labels);
    plhs[2] = util::numeric_vector_to_array(labs.ids, mxUINT32_CLASS);
}
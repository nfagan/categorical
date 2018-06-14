#include "cat_api.hpp"

namespace {
    
    void convert_all(const util::categorical* cat, const std::vector<std::string>& cats, 
            mxArray *plhs[], const mxArray *prhs[])
    {
        using util::u64;
        using util::u32;
        using std::vector;

        const char* func_id = "categorical:numcat";
        
        bool all_exist;

        util::labels_t labs = cat->get_labels_and_ids();
        vector<const vector<u32>*> all_ids = cat->get_label_mat(cats, &all_exist);
        
        if (!all_exist)
        {
            mexErrMsgIdAndTxt(func_id, "At least one category does not exist.");
        }

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
    
    void convert_indexed(const util::categorical* cat, const std::vector<std::string>& cats, 
            mxArray *plhs[], const mxArray *prhs[])
    {
        using util::u64;
        using util::u32;
        using std::vector;

        const char* func_id = "categorical:numcat";
        
        const u64* indices = (const u64*) mxGetData(prhs[3]);
        size_t n_indices = mxGetNumberOfElements(prhs[3]);
        
        bool all_exist;

        util::labels_t labs = cat->get_labels_and_ids();
        vector<const vector<u32>*> all_ids = cat->get_label_mat(cats, &all_exist);
        
        if (!all_exist)
        {
            mexErrMsgIdAndTxt(func_id, "At least one category does not exist.");
        }

        u64 n_cats = all_ids.size();
        u64 sz = cat->size();

        mxArray* mat = mxCreateUninitNumericMatrix(n_indices, n_cats, mxUINT32_CLASS, mxREAL);

        u32* data = (u32*) mxGetData(mat);
        
        u64 assign_idx = 0;

        for (u64 i = 0; i < n_cats; i++)
        {
            const vector<u32>* col = all_ids[i];
            const u32* src = col->data();
            
            for (u64 j = 0; j < n_indices; j++)
            {
                u64 idx = indices[j];
                
                //  bounds check
                if (idx == 0 || idx > sz)
                {
                    mxDestroyArray(mat);
                    mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
                }
                
                data[assign_idx] = src[idx-1];
                
                assign_idx++;
            }
        }

        plhs[0] = mat;
        plhs[1] = util::string_vector_to_array(labs.labels);
        plhs[2] = util::numeric_vector_to_array(labs.ids, mxUINT32_CLASS);
    }
}

void util::to_numeric_matrix(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    using util::u32;
    using std::vector;
    
    const char* func_id = "categorical:numcat";
    
    util::assert_nrhs(2, 4, nrhs, func_id);
    util::assert_nlhs(nlhs, 3, func_id);
    
    const util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    if (nrhs == 2)
    {
        convert_all(cat, cat->get_categories(), plhs, prhs);
        return;
    }
    else if (nrhs == 3)
    {
        std::vector<std::string> cats = util::get_strings(prhs[2], func_id);
        convert_all(cat, cats, plhs, prhs);
        return;
    } 
    else
    {
        std::vector<std::string> cats = util::get_strings(prhs[2], func_id);
        convert_indexed(cat, cats, plhs, prhs);
        return;
    }
}
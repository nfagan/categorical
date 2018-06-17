#include "cat_api.hpp"
#include <algorithm>

void util::set_partial_categories(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    using util::u32;
    using util::u64;
    
    const char* func_id = "categorical:setpartcat";
    
    util::assert_nrhs(nrhs, 5, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> cats = util::get_strings(prhs[2], func_id);
    std::vector<std::string> values = util::get_strings(prhs[3], func_id);
    
    std::vector<util::u64> at_indices = util::numeric_array_to_vector64(prhs[4], func_id);
    
    u64 sz = cat->size();
    u64 n_cats = cats.size();
    u64 n_values = values.size();
    u64 at_indices_sz = at_indices.size();
    u64 n_per_col;
    u64 index_offset = 1;
    
    bool is_scalar = false;
    
    if (n_cats == 0)
    {
        mexErrMsgIdAndTxt(func_id, "Cannot assign to 0 categories.");
    }
    
    if (at_indices_sz == 0)
    {
        mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
    }
    
    if (n_values == 1)
    {
        n_per_col = 1;
        is_scalar = true;
    }
    else if (n_values != at_indices_sz * n_cats)
    {
        mexErrMsgIdAndTxt(func_id, "Values exceed categorical dimensions.");
    }
    else
    {
        n_per_col = at_indices_sz;
    }
    
    std::vector<std::string> part_cat(n_per_col);
    
    for (u64 i = 0; i < n_cats; i++)
    {
        u64 start = is_scalar ? 0 : i * n_per_col;
        u64 stop = is_scalar ? 1 : start + n_per_col;
        
        std::copy(values.begin() + start, values.begin() + stop, part_cat.begin());
        
        u32 status = cat->set_category(cats[i], part_cat, at_indices, index_offset);

        if (status == util::categorical_status::OK)
        {
            continue;
        }

        if (status == util::categorical_status::CATEGORY_DOES_NOT_EXIST)
        {
            std::string msg = util::get_error_text_missing_category(cats[i]);
            mexErrMsgIdAndTxt(func_id, msg.c_str());
        }

        if (status == util::categorical_status::WRONG_CATEGORY_SIZE)
        {
            mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
        }

        if (status == util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY)
        {
            mexErrMsgIdAndTxt(func_id, util::get_error_text_label_exists().c_str());
        }

        if (status == util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY)
        {
            const char* msg = "Labels cannot contain the collapsed expression of a different category.";
            mexErrMsgIdAndTxt(func_id, msg);
        }

        if (status == util::categorical_status::WRONG_INDEX_SIZE)
        {
            mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
        }
        
        if (status == util::categorical_status::CAT_OVERFLOW)
        {
            mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
        }
        
        if (status == util::categorical_status::OUT_OF_BOUNDS)
        {
            mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
        }

        mexErrMsgIdAndTxt(func_id, "An unknown error ocurred.");
    
    }
}
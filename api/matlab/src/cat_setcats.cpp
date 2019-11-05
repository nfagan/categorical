#include "cat_api.hpp"
#include <algorithm>

void util::set_categories(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    using util::u32;
    
    const char* func_id = "categorical:setpartcat";
    
    util::assert_nrhs(4, 5, nrhs, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    std::vector<std::string> cats = util::get_strings(prhs[2], func_id);
    std::vector<std::string> values = util::get_strings(prhs[3], func_id);
    std::vector<u64> at_indices;
    
    const bool use_indices = nrhs == 5;
    
    if (use_indices)
    {
        at_indices = util::numeric_array_to_vector64(prhs[4], func_id);
    }
    
    const u64 index_offset = 1;
    const u64 n_cats = cats.size();
    const u64 n_values = values.size();
    
    if (n_values < n_cats || n_values % n_cats != 0)
    {
        mexErrMsgIdAndTxt(func_id, "Values exceed categorical dimensions.");
    }
    
    const u64 num_per_col = n_values / n_cats;
    std::vector<std::string> part_cat(num_per_col);
    
    for (u64 i = 0; i < n_cats; i++)
    {
        u64 start = i * num_per_col;
        u64 stop = start + num_per_col;
        
        std::copy(values.begin() + start, values.begin() + stop, part_cat.begin());
        
        u32 status;
        
        if (use_indices)
        {
            status = cat->set_category(cats[i], part_cat, at_indices, index_offset);
        }
        else
        {
            status = cat->set_category(cats[i], part_cat);
        }
        
        switch (status)
        {
            case util::categorical_status::OK:
                break;
            case util::categorical_status::CATEGORY_DOES_NOT_EXIST: 
            {
                std::string msg = util::get_error_text_missing_category(cats[i]);
                mexErrMsgIdAndTxt(func_id, msg.c_str());
                break;
            }
            case util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY:
                mexErrMsgIdAndTxt(func_id, util::get_error_text_label_exists().c_str());
                break;
            case util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY: 
            {
                const char* msg = "Labels cannot contain the collapsed expression of a different category.";
                mexErrMsgIdAndTxt(func_id, msg);
                break;
            }
            case util::categorical_status::WRONG_CATEGORY_SIZE:
            case util::categorical_status::WRONG_INDEX_SIZE:
            case util::categorical_status::CAT_OVERFLOW:
            case util::categorical_status::OUT_OF_BOUNDS:
                mexErrMsgIdAndTxt(func_id, "Indices exceed categorical dimensions.");
                break;
            default:
                mexErrMsgIdAndTxt(func_id, "An unknown error ocurred.");
                break;       
        }
    }
}
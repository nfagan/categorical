#include "cat_api.hpp"
#include <algorithm>

void util::set_categories(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using util::u64;
    using util::u32;
    
    const char* func_id = "categorical:setcats";
    
    util::assert_nrhs(nrhs, 4, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);    
    
    std::vector<std::string> cats = util::get_strings(prhs[2], func_id);
    std::vector<std::string> values = util::get_strings(prhs[3], func_id);
    
    u64 sz = cat->size();
    u64 n_cats = cats.size();
    u64 n_values = values.size();
    u64 n_per_col;
    
    bool is_scalar = false;
    
    if (n_cats == 0)
    {
        if (n_values != 0)
        {
            mexErrMsgIdAndTxt(func_id, "Values exceed categorical dimensions.");
        }
        
        return;
    }
    
    //
    //  make sure sizes properly correspond
    //
    
    if (n_values == 1)
    {
        is_scalar = true;
        n_per_col = 1;
    }
    else if (sz > 0)
    {
        if (n_values != sz * n_cats)
        {
            mexErrMsgIdAndTxt(func_id, "Values exceed categorical dimensions.");
        }
        
        n_per_col = sz;
    }
    else if ((n_values % n_cats) > 0)
    {
        mexErrMsgIdAndTxt(func_id, "Values exceed categorical dimensions.");
    }
    else
    {
        n_per_col = n_values / n_cats;
    }
    
    //
    //  set each cat
    //
    
    std::vector<std::string> full_cat(n_per_col);
    
    for (u64 i = 0; i < n_cats; i++)
    {
        
        u64 start = is_scalar ? 0 : i * n_per_col;
        u64 stop = is_scalar ? 1 : start + n_per_col;
        
        std::copy(values.begin() + start, values.begin() + stop, full_cat.begin());
        
        u32 status = cat->set_category(cats[i], full_cat);
    
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
    
        mexErrMsgIdAndTxt(func_id, "An unknown error ocurred.");
    }
}
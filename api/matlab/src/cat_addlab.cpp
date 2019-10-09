#include "cat_api.hpp"

namespace {
    std::string get_error_text_collapsed_expression_in_wrong_category(const std::string& label)
    {
        std::string message = std::string("Cannot add label '") + label;
        message += "' because it is the collapsed expression for a different category.";
        return message;
    }
    
    void add_label_impl(util::categorical* cat, const std::string& category, 
                        const std::string& label, const char* func_id) 
    {
        const util::u32 status = cat->add_label(category, label);
        
        switch (status)
        {
            case util::categorical_status::OK:
                break;
            case util::categorical_status::CATEGORY_DOES_NOT_EXIST: {
                const std::string message = util::get_error_text_missing_category(category);
                mexErrMsgIdAndTxt(func_id, message.c_str());
                break;
            }   
            case util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY: {
                std::string msg = util::get_error_text_label_exists();
                mexErrMsgIdAndTxt(func_id, msg.c_str());
                break;
            }
            case util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY: {
                const std::string message = get_error_text_collapsed_expression_in_wrong_category(label);
                mexErrMsgIdAndTxt(func_id, message.c_str());
                break;
            }
            default:
                mexErrMsgIdAndTxt(func_id, "An unknown error occurred.");
                break;
        }
    }
}

void util::add_label(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "categorical:addlab";
    
    util::assert_nrhs(nrhs, 4, func_id);
    util::assert_nlhs(nlhs, 0, func_id);
    
    util::categorical* cat = util::detail::mat_to_ptr<util::categorical>(prhs[1]);
    
    const mxArray* matlab_category = prhs[2];
    const mxArray* matlab_labels = prhs[3];
    
    if (mxGetClassID(matlab_category) == mxCHAR_CLASS)
    {
        const std::string category = util::get_string_with_trap(matlab_category, func_id);
        const std::vector<std::string> labels = util::get_strings(matlab_labels, func_id);

        for (const std::string& label : labels)
        {
            add_label_impl(cat, category, label, func_id);
        }
    } 
    else 
    {
        const std::vector<std::string> categories = util::get_strings(matlab_category, func_id);
        const std::vector<std::string> labels = util::get_strings(matlab_labels, func_id);
        
        if (categories.size() != labels.size())
        {
            mexErrMsgIdAndTxt(func_id, "Number of categories must match number of labels.");
        }
        
        for (std::size_t i = 0; i < categories.size(); i++)
        {
            add_label_impl(cat, categories[i], labels[i], func_id);
        }
    }
    
}
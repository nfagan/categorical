#include "cat_api.hpp"

namespace
{
    const char* error_text_wrong_collapsed_expression()
    {
        return "A collapsed expression for one category already exists in another category.";
    }
    
    void print_error_from_status(util::u32 status, const char* func_id)
    {
        switch (status)
        {
            case util::categorical_status::OUT_OF_BOUNDS:
                mexErrMsgIdAndTxt(func_id, "Index exceeds categorical dimensions.");
                break;
            case util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY:
                mexErrMsgIdAndTxt(func_id, error_text_wrong_collapsed_expression());
                break;
            case util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY:
                mexErrMsgIdAndTxt(func_id, util::get_error_text_label_exists().c_str());
                break;
            case util::categorical_status::CATEGORIES_DO_NOT_MATCH:
                mexErrMsgIdAndTxt(func_id, "Categories do not match.");
                break;
            case util::categorical_status::CATEGORY_DOES_NOT_EXIST:
                mexErrMsgIdAndTxt(func_id, "At least one category does not exist.");
                break;
            default:
                mexErrMsgIdAndTxt(func_id, "An unspecified error occurred.");
                break;
        }
    }
  
    void make_unique(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
    {
        using namespace util;
        
        const char* func_id = "categorical:make_unique";
        assert_min_nrhs(3, nrhs, func_id);
        
        const categorical* a = detail::mat_to_ptr<util::categorical>(prhs[2]);
        
        categorical tmp;
        u32 status = categorical_status::OK;
        
        if (nrhs == 3)
        {
            tmp = set_unique{*a}();
        }
        else
        {
            mexErrMsgIdAndTxt(func_id, "Expected 2 or 4 inputs.");
        }

        if (status != categorical_status::OK)
        {
            print_error_from_status(status, func_id);
        }

        categorical* cat = new categorical(std::move(tmp));
        plhs[0] = detail::ptr_to_mat<categorical>(cat);
    }
  
    void make_union(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
    {
        using namespace util;
        
        const char* func_id = "categorical:make_union";
        assert_min_nrhs(4, nrhs, func_id);
        
        const categorical* a = detail::mat_to_ptr<util::categorical>(prhs[2]);
        const categorical* b = detail::mat_to_ptr<util::categorical>(prhs[3]);
        
        categorical tmp;
        u32 status = categorical_status::OK;
        
        util::set_membership::options options;
        options.index_offset = 1;
        
        if (nrhs == 4)
        {
            tmp = set_union{*a, *b, options}.make_union(&status);
        }
        else if (nrhs == 5)
        {
            const std::vector<std::string> categories = get_strings(prhs[4], func_id);
            tmp = set_union{*a, *b, options}.make_union(categories, &status);
        }
        else if (nrhs == 6)
        {
            const std::vector<u64> mask_a = double_or_uint64_array_to_vector64(prhs[4], func_id);
            const std::vector<u64> mask_b = double_or_uint64_array_to_vector64(prhs[5], func_id);

            tmp = set_union{*a, *b, options}.make_union(mask_a, mask_b, &status);
        }
        else if (nrhs == 7)
        {
            const std::vector<std::string> categories = get_strings(prhs[4], func_id);
            const std::vector<u64> mask_a = double_or_uint64_array_to_vector64(prhs[5], func_id);
            const std::vector<u64> mask_b = double_or_uint64_array_to_vector64(prhs[6], func_id);
            const u64 index_offset = 1;
            
            tmp = set_union{*a, *b, options}.make_union(categories, mask_a, mask_b, &status);
        }
        else
        {
            mexErrMsgIdAndTxt(func_id, "Expected 2 or 4 inputs.");
        }

        if (status != categorical_status::OK)
        {
            print_error_from_status(status, func_id);
        }

        categorical* cat = new categorical(std::move(tmp));
        plhs[0] = detail::ptr_to_mat<categorical>(cat);
    }
    
    void make_combined(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
    {        
        using namespace util;
        
        const char* func_id = "categorical:make_combined";
        assert_min_nrhs(4, nrhs, func_id);
        
        const categorical* a = detail::mat_to_ptr<util::categorical>(prhs[2]);
        const categorical* b = detail::mat_to_ptr<util::categorical>(prhs[3]);

        categorical tmp;
        u32 status = categorical_status::OK;
        
        util::set_membership::options options;
        options.index_offset = 1;
        
        if (nrhs == 4)
        {
            tmp = set_union{*a, *b, options}.make_combined(&status);
        }
        else if (nrhs == 6)
        {
            const std::vector<u64> mask_a = double_or_uint64_array_to_vector64(prhs[4], func_id);
            const std::vector<u64> mask_b = double_or_uint64_array_to_vector64(prhs[5], func_id);

            tmp = set_union{*a, *b, options}.make_combined(mask_a, mask_b, &status);
        }
        else
        {
            mexErrMsgIdAndTxt(func_id, "Expected 2 or 4 inputs.");
        }

        if (status != categorical_status::OK)
        {
            print_error_from_status(status, func_id);
        }

        categorical* cat = new categorical(std::move(tmp));
        plhs[0] = detail::ptr_to_mat<categorical>(cat);
    }
}

void util::set_membership_handler(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    using namespace util;
    using std::vector;
    
    const char* func_id = "categorical:set_membership";
    assert_nlhs(nlhs, 1, func_id);
    assert_min_nrhs(3, nrhs, func_id);
    
    const char* kind_err_msg = "Function id must be a uint32 scalar.";
    const u32 func_kind = get_scalar_with_trap<u32>(prhs[1], mxUINT32_CLASS, func_id, kind_err_msg);
    
    switch (func_kind)
    {
        case 0:
            make_combined(nlhs, plhs, nrhs, prhs);
            break;
        case 1:
            make_union(nlhs, plhs, nrhs, prhs);
            break;
        case 2:
            make_unique(nlhs, plhs, nrhs, prhs);
            break;
        default:
            mexErrMsgIdAndTxt(func_id, "Unrecognized function kind."); 
    }
}
#include "cat_mex_helpers.hpp"

std::string util::get_error_text_missing_category(const std::string& category)
{
    std::string msg = "The category '" + category + "' does not exist.";
    return msg;
}

std::string util::get_error_text_present_category(const std::string& category)
{
    std::string msg = "The category '" + category + "' already exists.";
    return msg;
}

std::string util::get_error_text_label_exists()
{
    return "A given label already exists in another category.";
}

std::string util::get_error_text_missing_label(const std::string& lab)
{
    return "The label '" + lab + "' does not exist.";
}

mxArray* util::string_vector_to_array(const std::vector<std::string>& in_vec)
{
    uint64_t sz = in_vec.size();
    
    mxArray* strs = mxCreateCellMatrix(sz, 1);
    
    for (uint64_t i = 0; i < sz; i++)
    {
        mxArray* str = mxCreateString(in_vec[i].c_str());
        mxSetCell(strs, i, str);
    }
    
    return strs;
}

void util::assign_string_vector_to_array(const std::vector<std::string>& in_vec, 
        mxArray* out_cell, uint64_t start_idx)
{
    uint64_t sz = in_vec.size();
    
    for (uint64_t i = 0; i < sz; i++)
    {
        mxArray* str = mxCreateString(in_vec[i].c_str());
        mxSetCell(out_cell, i + start_idx, str);
    }
}

std::vector<std::string> util::get_strings(const mxArray* in_strs, const char* id)
{
    mxClassID strs_class = mxGetClassID(in_strs);
    
    if (strs_class == mxCHAR_CLASS)
    {
        bool success;
        
        std::string str = util::get_string(in_strs, &success);
        
        if (!success)
        {
            mexErrMsgIdAndTxt(id, "Cannot convert to string from given values.");
        }
        
        std::vector<std::string> res = { str };
        
        return res;
    }
    
    if (strs_class != mxCELL_CLASS)
    {
        mexErrMsgIdAndTxt(id, "Input must be a cell array of strings.");
    }
    
    size_t n_els = mxGetNumberOfElements(in_strs);
    
    std::vector<std::string> strs(n_els);
    
    for (size_t i = 0; i < n_els; i++)
    {
        const mxArray* str_arr = mxGetCell(in_strs, i);
        
        strs_class = mxGetClassID(str_arr);
        
        if (strs_class != mxCHAR_CLASS)
        {
            mexErrMsgIdAndTxt(id, "Input must be a cell array of strings.");
        }
        
        bool success;
        
        std::string str = util::get_string(str_arr, &success);
        
        if (!success)
        {
            mexErrMsgIdAndTxt(id, "Cannot convert to string from given values.");
        }
        
        strs[i] = str;
    }
    
    return strs;
}

std::string util::get_string(const mxArray* in_str, bool* success)
{    
    uint64_t sz = mxGetNumberOfElements(in_str);
    
    size_t strlen = (sz+1) * sizeof(char);
    
    char* str = (char*) std::malloc(strlen);
    
    if (str == nullptr)
    {
        *success = false;
        return "";
    }
    
    int result = mxGetString(in_str, str, strlen);
    
    if (result != 0)
    {
        std::free(str);
        *success = false;
        return "";
    }
    
    *success = true;
    
    std::string res(str);
    std::free(str);
    
    return res;
}

std::string util::get_string_with_trap(const mxArray* in_str, const char* id)
{    
    uint64_t sz = mxGetNumberOfElements(in_str);
    
    size_t strlen = (sz+1) * sizeof(char);
    
    char* str = (char*) std::malloc(strlen);
    
    if (str == nullptr)
    {
        mexErrMsgIdAndTxt(id, "String memory allocation failed.");
        return "";
    }
    
    int result = mxGetString(in_str, str, strlen);
    
    if (result != 0)
    {
        std::free(str);
        mexErrMsgIdAndTxt(id, "String copy failed.");
    }
    
    std::string res(str);
    std::free(str);
    
    return res;
}

std::vector<uint64_t> util::numeric_array_to_vector64(const mxArray* in_arr, const char* func_id)
{
    
    mxClassID id = mxGetClassID(in_arr);
    
    if (id != mxUINT64_CLASS)
    {
        mexErrMsgIdAndTxt(func_id, "Input must be uint64.");
    }
    
    uint64_t n_els = mxGetNumberOfElements(in_arr);
    
    if (n_els == 0)
    {
        return std::vector<uint64_t>();
    }
    
    std::vector<uint64_t> res(n_els);
    
    uint64_t* src = (uint64_t*) mxGetData(in_arr);
    
    std::memcpy(res.data(), src, n_els * sizeof(uint64_t));
    
    return res;
}

std::vector<uint32_t> util::numeric_array_to_vector32(const mxArray* in_arr, const char* func_id)
{
    
    mxClassID id = mxGetClassID(in_arr);
    
    if (id != mxUINT32_CLASS)
    {
        mexErrMsgIdAndTxt(func_id, "Input must be uint32.");
    }
    
    uint64_t n_els = mxGetNumberOfElements(in_arr);
    
    if (n_els == 0)
    {
        return std::vector<uint32_t>();
    }
    
    std::vector<uint32_t> res(n_els);
    
    uint32_t* src = (uint32_t*) mxGetData(in_arr);
    
    std::memcpy(res.data(), src, n_els * sizeof(uint32_t));
    
    return res;
}

void util::assert_scalar(const mxArray *arr, const char* id, const char* msg)
{
    if (!mxIsScalar(arr))
    {
        mexErrMsgIdAndTxt(id, msg);
    }
}

void util::assert_nrhs(int actual, int expected, const char* id)
{
    if (actual != expected)
    {
        mexErrMsgIdAndTxt(id, "Wrong number of inputs.");
    }
}

void util::assert_nrhs(int minimum, int maximum, int actual, const char* id)
{
    if (actual < minimum || actual > maximum)
    {
        mexErrMsgIdAndTxt(id, "Wrong number of inputs.");
    }
}

void util::assert_nlhs(int actual, int expected, const char* id)
{
    if (actual != expected)
    {
        mexErrMsgIdAndTxt(id, "Wrong number of outputs.");
    }
}

void util::assert_nlhs(int minimum, int maximum, int actual, const char* id)
{
    if (actual < minimum || actual > maximum)
    {
        mexErrMsgIdAndTxt(id, "Wrong number of outputs.");
    }
}

void util::assert_isa(const mxArray *arr, unsigned int class_id, const char* id, const char* msg)
{
    if (mxGetClassID(arr) != class_id)
    {
        mexErrMsgIdAndTxt(id, msg);
        return;
    }
}
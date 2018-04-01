#include "mex_helpers.hpp"

void util::assert_ndimensions(const mxArray* arr, size_t ndims, const char* id)
{
    size_t actual_ndims = mxGetNumberOfDimensions(arr);

    if (actual_ndims != ndims)
    {
        std::string expected_str = std::to_string(ndims);
        std::string actual_str = std::to_string(actual_ndims);
        std::string err_msg = "Expected input to have ";

        err_msg += expected_str;
        err_msg += " dimensions; instead " + actual_str + " were present.";

        mexErrMsgIdAndTxt(id, err_msg.c_str());
    }
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
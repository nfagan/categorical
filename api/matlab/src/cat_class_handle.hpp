#pragma once

#include "mex.h"
#include <cstdint>
#include <string>
#include <cstring>
#include <typeinfo>

#define CLASS_HANDLE_SIGNATURE 0xFF00F0A5

// #define CAT_MEX_LOCK

namespace util {
namespace detail {

template<class base> class class_handle
{
public:
    class_handle(base *ptr) : signature_m(CLASS_HANDLE_SIGNATURE), name_m(typeid(base).name()), ptr_m(ptr) {}
    ~class_handle() { signature_m = 0; delete ptr_m; }
    bool is_valid() { return ((signature_m == CLASS_HANDLE_SIGNATURE) && !strcmp(name_m.c_str(), typeid(base).name())); }
    base* ptr() { return ptr_m; }

private:
    uint32_t signature_m;
    const std::string name_m;
    base* const ptr_m;
};

template<class base> inline mxArray *ptr_to_mat(base *ptr)
{
#ifdef CAT_MEX_LOCK
    mexLock();
#endif
    mxArray *out = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    *((uint64_t *)mxGetData(out)) = reinterpret_cast<uint64_t>(new class_handle<base>(ptr));
    return out;
}

template<class base> inline class_handle<base> *mat_to_handle_ptr(const mxArray *in)
{
    if (mxGetNumberOfElements(in) != 1 || mxGetClassID(in) != mxUINT64_CLASS || mxIsComplex(in))
        mexErrMsgTxt("Input must be a real uint64 scalar.");
    class_handle<base> *ptr = reinterpret_cast<class_handle<base> *>(*((uint64_t *)mxGetData(in)));
    if (!ptr->is_valid())
        mexErrMsgTxt("Handle not valid.");
    return ptr;
}

template<class base> inline bool is_valid_ptr(const mxArray *in)
{
    if (mxGetNumberOfElements(in) != 1 || mxGetClassID(in) != mxUINT64_CLASS || mxIsComplex(in))
        return false;
    class_handle<base> *ptr = reinterpret_cast<class_handle<base> *>(*((uint64_t *)mxGetData(in)));
    return ptr->is_valid();
}

template<class base> inline base *mat_to_ptr(const mxArray *in)
{
    return mat_to_handle_ptr<base>(in)->ptr();
}

template<class base> inline void destroy(const mxArray *in)
{
    delete mat_to_handle_ptr<base>(in);
#ifdef CAT_MEX_LOCK
    mexUnlock();
#endif
}

}
    
}

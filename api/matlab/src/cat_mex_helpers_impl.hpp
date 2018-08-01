template<typename T>
mxArray* util::numeric_vector_to_array(const std::vector<T>& in_vec, mxClassID output_kind)
{
    uint64_t sz = in_vec.size();
            
    mxArray* out = mxCreateUninitNumericMatrix(sz, 1, output_kind, mxREAL);
    
    T* data = (T*) mxGetData(out);
    
    std::memcpy(data, &in_vec[0], sz * sizeof(T));
    
    return out;
}

template<typename T>
T util::get_scalar_with_trap(const mxArray* in_arr, unsigned int class_id, const char* func_id, const char* msg)
{
    util::assert_isa(in_arr, class_id, func_id, msg);
    util::assert_scalar(in_arr, func_id, msg);
    
    T* data = (T*) mxGetData(in_arr);
    
    return data[0];
}
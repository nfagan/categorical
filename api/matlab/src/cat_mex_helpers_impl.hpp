template<typename T>
mxArray* util::numeric_vector_to_array(const std::vector<T>& in_vec, mxClassID output_kind)
{
    uint64_t sz = in_vec.size();
            
    mxArray* out = mxCreateUninitNumericMatrix(sz, 1, output_kind, mxREAL);
    
    T* data = (T*) mxGetData(out);
    
    std::memcpy(data, &in_vec[0], sz * sizeof(T));
    
    return out;
}
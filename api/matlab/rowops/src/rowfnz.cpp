#include "rowops.hpp"

namespace util {

    void rowfnz(double* in_data, size_t m_in, size_t n_in, 
            double* out_data, size_t out_row, size_t out_rows, 
            uint64_t* indices, size_t n_indices)
    {        
        for (size_t i = 0; i < n_in; i++)
        {
            double sum = 0.0;
            
            for (size_t j = 0; j < n_indices; j++)
            {
                sum += in_data[(indices[j] - 1) + (i * m_in)];
            }
            
            sum /= double(n_indices);
            
            out_data[out_row + i * out_rows] = sum;
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "mean:main";
    
    util::run(nlhs, plhs, nrhs, prhs, func_id, &util::rowmean);
}
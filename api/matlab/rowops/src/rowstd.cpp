#include "rowops.hpp"
#include <cmath>

namespace util {

    void rowstd(double* in_data, size_t m_in, size_t n_in, 
            double* out_data, size_t out_row, size_t out_rows, 
            uint64_t* indices, size_t n_indices)
    {        
        for (size_t i = 0; i < n_in; i++)
        {
            //  first calculate mean
            double mn = 0.0;
            
            for (size_t j = 0; j < n_indices; j++)
            {
                mn += in_data[(indices[j] - 1) + (i * m_in)];
            }
            
            mn /= double(n_indices);
            
            //  then calculate deviation from mean
            double sum = 0.0;
            
            for (size_t j = 0; j < n_indices; j++)
            {
                double val = in_data[(indices[j] - 1) + (i * m_in)] - mn;
                
                sum += (val * val);
            }
            
            //  matlab normalizes by N-1 if N indices is > 1, or 1 if N
            //  indices is 1.
            size_t denom;
            
            if (n_indices == 1)
            {
                denom = 1;
            }
            else
            {
                denom = n_indices - 1;
            }
            
            sum /= double(denom);
            
            out_data[out_row + i * out_rows] = sqrt(sum);
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "mean:main";
    
    util::run(nlhs, plhs, nrhs, prhs, func_id, &util::rowstd);
}
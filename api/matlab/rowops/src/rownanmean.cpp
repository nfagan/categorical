#include "rowops.hpp"
#include <cmath>

namespace util {

    void rownanmean(double* in_data, size_t m_in, size_t n_in, 
            double* out_data, size_t out_row, size_t out_rows, 
            uint64_t* indices, size_t n_indices)
    {        
        for (size_t i = 0; i < n_in; i++)
        {
            double sum = 0.0;
            double iters = 0.0;
            
            for (size_t j = 0; j < n_indices; j++)
            {
                double val = in_data[(indices[j] - 1) + (i * m_in)];
                
                if (std::isnan(val))
                {
                    continue;
                }
                
                sum += val;
                iters += 1.0;
            }
            
            sum /= iters;
            
            out_data[out_row + i * out_rows] = sum;
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    const char* func_id = "nanmean:main";
    
    util::run(nlhs, plhs, nrhs, prhs, func_id, &util::rownanmean);
}
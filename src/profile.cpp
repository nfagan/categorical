//
//  profile.cpp
//  bit_array-test
//
//  Created by Nick Fagan on 2/28/18.
//

#include "profile.hpp"
#include <iostream>

void util::profile::simple(std::function<double(void)> func, std::string alias, uint32_t n_iters)
{
    double mean = 0.0;
    double iters = 0.0;
    double total_time = 0.0;
    
    for (uint32_t i = 0; i < n_iters; i++)
    {
        double res = func();
        mean = (mean * iters + res) / (iters + 1.0);
        iters += 1.0;
        total_time += res;
    }
    
    std::cout << alias << " (mean): " << (mean * 1000.0) << " (ms) " << std::endl;
    std::cout << alias << " (total) " << (total_time * 1000.0) << " (ms) ";
    std::cout << "[" << n_iters << " iters]" << std::endl;
    std::cout << "--" << std::endl;
}

double util::profile::ellapsed_time_s(util::profile::time_point_t t1, util::profile::time_point_t t2)
{
    return std::chrono::duration_cast<std::chrono::duration<double>>(t2 - t1).count();
}

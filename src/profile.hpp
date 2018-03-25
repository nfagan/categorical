//
//  profile.hpp
//  locator
//
//  Created by Nick Fagan on 2/28/18.
//

#pragma once

#include <functional>
#include <string>
#include <chrono>
#include <iostream>

namespace util {
    namespace profile {
        typedef std::chrono::high_resolution_clock clock_t;
        typedef std::chrono::high_resolution_clock::time_point time_point_t;
        
        void simple(std::function<double(void)> func, std::string alias, uint32_t n_iters);
        
        double ellapsed_time_s(time_point_t t1, time_point_t t2);
    }
}

#define LOC_PROFILE_BEGIN() \
    util::profile::time_point_t t1, t2;

#define LOC_PROFILE_START() \
    t1 = util::profile::clock_t::now();

#define LOC_PROFILE_STOP() \
    t2 = util::profile::clock_t::now();

#define LOC_PROFILE_SUMMARY(label) \
    std::cout << #label << (util::profile::ellapsed_time_s(t1, t2) * 1000.0) << " (ms)" << std::endl;

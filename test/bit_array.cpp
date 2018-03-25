#include "bit_array.hpp"
#include <iostream>
#include <assert.h>
#include <chrono>
#include <cmath>
#include <vector>
#include <thread>
#include "utilities.hpp"

void test_iterator();
void test_all();
void test_resize();
void test_append_one();
void test_bit_array();
void test_bit_array_copy();
void test_threaded_accessor();
double test_fast_threaded_access(uint32_t sz, bool use_thread, uint32_t n_threads);
void test_thread2();
double test_keep(uint32_t sz);
void test_keep_multi(uint32_t n_iters);
double test_append();
void test_append_multi();
double test_append_speed(uint32_t sz);
double ellapsed_time_s(std::chrono::high_resolution_clock::time_point t1, std::chrono::high_resolution_clock::time_point t2);
void test_basic();
double test_append_unaligned(uint32_t sz);
void test_append_unaligned_multi();
double test_sum(uint32_t sz);
void test_sum_multi();
double test_find(uint32_t sz);
void test_find_multi();
void test_any_all();
void test_assign_true();
double test_profile_append(uint32_t sz);
double test_profile_resize(uint32_t sz);

int main(int argc, char* argv[])
{
    std::cout << "BEGIN BIT_ARRAY" << std::endl;
    test_iterator();
    test_resize();
    test_append_one();
    test_any_all();
    test_basic();
    test_any_all();
    test_assign_true();
    test_find_multi();
    test_sum_multi();
    test_bit_array();
    test_append_unaligned_multi();
//    test_thread2();
    test_keep_multi(1000);
    test_append_multi();
    
    util::profile::simple(std::bind(test_profile_append, 1e3), "append", 1e3);
    util::profile::simple(std::bind(test_profile_resize, 1e3), "resize", 1e3);
    
    std::cout << "END BIT_ARRAY" << std::endl;
    
    return 0;
}

double test_profile_append(uint32_t sz = 1e3)
{
    using namespace util;
    
    bit_array barray(sz, true);
    
    profile::time_point_t t1 = profile::clock_t::now();
    
    barray.append(bit_array(sz, false));
    
    profile::time_point_t t2 = profile::clock_t::now();
    
    return profile::ellapsed_time_s(t1, t2);
}

double test_profile_resize(uint32_t sz = 1e3)
{
    using namespace util;
    
    bit_array barray(sz, true);
    
    profile::time_point_t t1 = profile::clock_t::now();
    
    barray.resize(sz*2);
    
    profile::time_point_t t2 = profile::clock_t::now();
    
    return profile::ellapsed_time_s(t1, t2);
}

void test_iterator()
{
    using namespace util;
    
    bit_array barray(101, false);
    
    auto it = barray.begin();
    uint32_t sz = barray.size();
    
    for (uint32_t i = 0; i < sz; i++)
    {
        assert(!it.value());
        it.next();
    }
    
    barray.place(true, 30);
    barray.place(true, 33);
    
    it = barray.begin();
    
    for (uint32_t i = 0; i < sz; i++)
    {
        bool value = it.value();
        
        assert((i == 30 || i == 33 ? value : !value));
        
        it.next();
    }
    
    std::cout << "OK" << std::endl;
}

void test_resize()
{
    using namespace util;
    
    for (uint32_t i = 0; i < 10000; i++)
    {
        bit_array barray;
        
        barray.resize(i);
        
        assert(barray.size() == i);
        
        assert(!barray.any());
    }
    
    for (uint32_t i = 0; i < 1000; i++)
    {
        uint32_t sz = rand() % 100;
        uint32_t new_sz = 100 + rand() % 100;
        bit_array barray(sz);
        
        barray.fill(true);
        
        barray.resize(new_sz);
        
        assert(barray.size() == new_sz);
        
        auto inds = bit_array::find(barray);
        
        uint32_t search_sz = new_sz > sz ? sz : new_sz;
        
        assert(inds.tail() == search_sz);
        
        if (inds.tail() > 0)
        {
            assert(inds.at(inds.tail()-1) == search_sz-1);
        }
    }
    
    for (uint32_t i = 0; i < 1000; i++)
    {
        uint32_t sz = 100 + rand() % 100;
        uint32_t new_sz = rand() % 100;
        
        bit_array barray(sz);
        
        barray.fill(true);
        
        barray.resize(new_sz);
        
        assert(barray.size() == new_sz);
        
        auto inds = bit_array::find(barray);
        
        assert(inds.tail() == new_sz);
        
        if (inds.tail() > 0)
        {
            assert(inds.at(inds.tail()-1) == new_sz-1);
        }
    }
    
    for (uint32_t i = 0; i < 1000; i++)
    {
        uint32_t sz = 1 + rand() % 100;
        uint32_t new_sz = rand() % 100 + 101;
        
        bit_array barray(sz, false);
        
        barray.place(true, sz-1);
        
        barray.resize(new_sz);
        
        auto inds = bit_array::find(barray);
        
        assert(inds.tail() == 1 && inds.at(0) == sz-1);
    }
    
    for (uint32_t i = 0; i < 1000; i++)
    {
        uint32_t sz = rand() % 10000;
        uint32_t new_sz = 0;
        
        bit_array barray(sz, true);
        
        barray.resize(new_sz);
        
        assert(barray.sum() == 0);
        assert(!barray.any());
    }
}

void test_append_one()
{
    using namespace util;
    
    bit_array barray;
    
    for (uint32_t i = 0; i < 10000; i++)
    {
        bit_array barray2(1, true);
        
        barray.append(barray2);
        
        assert(barray.at(i));
        assert(barray.size() == i+1);
        assert(barray.all());
        assert(barray.any());
        
        auto ind = bit_array::find(barray);
        
        assert(ind.size() == barray.size());
    }
}

void test_any_all()
{
    using namespace util;
    
    for (uint32_t i = 0; i < 100000; i++)
    {
        bit_array barray(i, false);
        
        assert(!barray.all());
        assert(!barray.any());
        
        barray.fill(true);
        
        if (i == 0)
        {
            assert(!barray.any());
            assert(!barray.all());
            continue;
        }
        
        assert(barray.any());
        assert(barray.all());
        
        barray.fill(false);
        
        if (i < 101)
        {
            continue;
        }
        
        for (uint32_t j = 0; j < 100; j++)
        {
            uint32_t idx = rand() % 100;
            barray.place(true, idx);
        }
        
        assert(barray.any());
        assert(!barray.all());
    }
    
    for (uint32_t i = 2; i < 100000; i++)
    {
        bit_array barray(i, false);
        
        barray.place(true, rand() % (i-1));
        
        assert(barray.any());
        assert(!barray.all());
    }
    
    bit_array barray;
    
    assert(!barray.any());
    assert(!barray.all());
}

void test_assign_true()
{
    using namespace util;
    typedef dynamic_array<util::u64> data_t;
    
    uint32_t sz = 103;
    uint32_t indices_size = 50;
    
    bit_array barray(sz);
    
    barray.fill(false);
    
    assert(!barray.any());
    
    data_t at_indices;
    
    for (uint32_t i = 0; i < indices_size; i++)
    {
        at_indices.push(i);
    }
    
    barray.unchecked_assign_true(at_indices);
    
    assert(barray.sum() == at_indices.tail());
    
    for (uint32_t i = 0; i < at_indices.tail(); i++)
    {
        assert(barray.at(at_indices.at(i)));
    }
}

void test_any()
{
    using namespace util;
    
    bit_array barray;
    
    uint32_t sz = 101;
    
    barray.push(false);
    barray.push(false);
    barray.push(false);
    
    assert(!barray.any());
    
    bit_array barray2(sz);
    
    barray2.fill(true);
    
    assert(barray2.any());
    
    bit_array barray3(sz);
    barray3.fill(false);
    
    assert(!barray3.any());
    
    barray3.place(true, sz-1);
    
    assert(barray3.any());
}

void test_find_multi()
{
    double mean = 0.0;
    double iters = 0.0;
    double total_time = 0.0;
    uint32_t sz = 1e5 + 2032;
    
    uint32_t n_iters = 1000;
    
    for (uint32_t i = 0; i < n_iters; i++)
    {
        double res = test_find(sz);
        mean = (mean * iters + res) / (iters + 1.0);
        iters += 1.0;
        total_time += res;
    }
    
    std::cout << "Mean time: (find) " << (mean * 1000.0) << " (ms), ";
    std::cout << sz << " (elements)" << std::endl;
    std::cout << "Total time: (find) " << (total_time * 1000.0) << " (ms)" << std::endl;
    std::cout << "--" << std::endl;
}

double test_find(uint32_t sz)
{
    using namespace util;
    using namespace std::chrono;
    
    high_resolution_clock::time_point t1;
    high_resolution_clock::time_point t2;
    
    uint32_t n_indices = 100;
    uint32_t n_assigned = 0;
    
    bit_array barray(sz);
    dynamic_array<util::u64> assign_indices(n_indices);
    
    assign_indices.seek_tail_to_start();
    
    barray.fill(false);
    
    for (uint32_t i = 0; i < n_indices; i++)
    {
        uint32_t assign_idx = rand() % sz;
        if (!barray.at(assign_idx))
        {
            barray.place(true, assign_idx);
            assign_indices.push(assign_idx);
            n_assigned++;
        }
    }
    
    assert(barray.sum() == n_assigned);
    
    t1 = high_resolution_clock::now();
    
    dynamic_array<util::u64> found_indices = bit_array::find(barray);
    
    t2 = high_resolution_clock::now();
    
    assert(found_indices.tail() == n_assigned);
    
    util::u64* found_data = found_indices.unsafe_get_pointer();
    
    for (uint32_t i = 0; i < found_indices.tail(); i++)
    {
        assert(barray.at(found_data[i]));
    }
    
    bit_array barray2(sz);
    
    barray2.fill(true);
    
    assign_indices.resize(0);
    n_assigned = 0;
    
    for (uint32_t i = 0; i < n_indices; i++)
    {
        uint32_t assign_idx = rand() % sz;
        if (barray2.at(assign_idx))
        {
            barray2.place(false, assign_idx);
            assign_indices.push(assign_idx);
            n_assigned++;
        }
    }
    
    barray2.flip();
    
    found_indices = bit_array::find(barray2);
    found_data = found_indices.unsafe_get_pointer();
    
    assert(found_indices.tail() == n_assigned);
    
    for (uint32_t i = 0; i < found_indices.tail(); i++)
    {
        assert(barray2.at(found_data[i]));
    }
    
    return ellapsed_time_s(t1, t2);
}

void test_sum_multi()
{
    double mean = 0.0;
    double iters = 0.0;
    double total_time = 0.0;
    uint32_t sz = 1e5;
    
    uint32_t n_iters = 1000;
    
    for (uint32_t i = 0; i < n_iters; i++)
    {
        double res = test_sum(sz);
        mean = (mean * iters + res) / (iters + 1.0);
        iters += 1.0;
        total_time += res;
    }
    
    std::cout << "Mean time: (sum) " << (mean * 1000.0) << " (ms), ";
    std::cout << sz << " (elements)" << std::endl;
    std::cout << "Total time: (sum) " << (total_time * 1000.0) << " (ms)" << std::endl;
    std::cout << "--" << std::endl;
}

double test_sum(uint32_t sz)
{
    using namespace util;
    using namespace std::chrono;
    
    high_resolution_clock::time_point t1;
    high_resolution_clock::time_point t2;
    
    bit_array barray(sz);
    bit_array barray2(sz);
    
    barray.fill(true);
    barray2.fill(false);
    
    uint32_t n_flip = 100;
    
    for (uint32_t i = 0; i < n_flip; i++)
    {
        barray.place(false, i);
        barray2.place(true, i);
    }
    
    assert(barray.sum() == sz - n_flip);
    assert(barray2.sum() == n_flip);
    
    t1 = high_resolution_clock::now();
    
    uint32_t res = barray.sum();
    
    t2 = high_resolution_clock::now();
    
    return ellapsed_time_s(t1, t2);
}

void test_append_unaligned_multi()
{
    double mean = 0.0;
    double iters = 0.0;
    double total_time = 0.0;
    uint32_t sz = (1e5 + 11);
    
    uint32_t n_iters = 1000;
    
    for (uint32_t i = 0; i < n_iters; i++)
    {
        double res = test_append_unaligned(sz);
        mean = (mean * iters + res) / (iters + 1.0);
        iters += 1.0;
        total_time += res;
    }
    
    std::cout << "Mean time: (append-unaligned) " << (mean * 1000.0) << " (ms), ";
    std::cout << sz << " (elements)" << std::endl;
    std::cout << "Total time: (append-unaligned) " << (total_time * 1000.0) << " (ms)" << std::endl;
    std::cout << "--" << std::endl;
}

double test_append_unaligned(uint32_t sz)
{
    using namespace util;
    using namespace std::chrono;
    
    high_resolution_clock::time_point t1;
    high_resolution_clock::time_point t2;
    
    int size_a = 102;
    int size_b = sz;
    
    bit_array barray(size_a);
    bit_array barray2(size_b);
    
    bool fill_a = false;
    bool fill_b = true;
    
    barray.fill(fill_a);
    barray2.fill(fill_b);
    
    barray.place(fill_b, size_a - 2);
    
    t1 = high_resolution_clock::now();
    
    barray.append(barray2);
    
    t2 = high_resolution_clock::now();
    
    assert(barray.size() == size_a + size_b);
    
    assert(barray.at(size_a-1) == fill_a);
    assert(barray.at(size_a-2) == fill_b);
    
    for (uint32_t i = size_a; i < barray.size(); i++)
    {
        assert(barray.at(i) == barray2.at(i - size_a));
    }
    
    return ellapsed_time_s(t1, t2);
}

void test_basic()
{    
    using namespace util;
    
    bit_array barray4;
    barray4.fill(true);
    
    for (uint32_t i = 0; i < 10000; i++)
    {
        barray4.push(true);
    }
    
    bit_array barray(101);
    barray.fill(false);
    
    for (uint32_t i = 0; i < 10000; i++)
    {
        barray.push(true);
    }
    
    assert(barray.at(101));
}

void test_append_multi()
{
    double mean = 0.0;
    double iters = 0.0;
    double total_time = 0.0;
    uint32_t sz = 1e7;
    
    uint32_t n_iters = 1000;
    
    for (uint32_t i = 0; i < n_iters; i++)
    {
        double res = test_append_speed(sz);
        mean = (mean * iters + res) / (iters + 1.0);
        iters += 1.0;
        total_time += res;
    }
    
    std::cout << "Mean time: (append) " << (mean * 1000.0) << " (ms), ";
    std::cout << sz << " (elements)" << std::endl;
    std::cout << "Total time: (append) " << (total_time * 1000.0) << " (ms)" << std::endl;
    std::cout << "--" << std::endl;
}

double test_append_speed(uint32_t sz)
{
    using namespace util;
    std::chrono::high_resolution_clock::time_point t1;
    std::chrono::high_resolution_clock::time_point t2;
    
    t1 = std::chrono::high_resolution_clock::now();
    
    bit_array barray(sz);
    bit_array barray2(sz);
    
    barray.fill(false);
    barray2.fill(false);
    
//    t1 = std::chrono::high_resolution_clock::now();
    barray.append(barray2);
    t2 = std::chrono::high_resolution_clock::now();
    
    return ellapsed_time_s(t1, t2);
}

double test_append()
{
    
    using namespace util;
    std::chrono::high_resolution_clock::time_point t1;
    std::chrono::high_resolution_clock::time_point t2;
    
    bit_array barray3(0);
    bit_array barray4(10);
    
    barray3.fill(false);
    barray4.fill(true);
    
    barray3.append(barray4);
    
    assert(barray3.size() == barray4.size());
    assert(barray3.all());
    for (uint32_t i = 0; i < barray3.size(); i++)
    {
        assert(barray3.at(i));
    }
    
    uint32_t sz = 1e6;
    
    bit_array barray(sz);
    bit_array barray2(sz);
    
    barray.fill(false);
    barray2.fill(false);
    
    barray2.place(true, 0);
    barray2.place(true, 1);
    
//    std::cout << "Before append: ";
    
    for (uint32_t i = 0; i < sz; i++)
    {
        assert(!barray.at(i));
    }
    
//    std::cout << "Ok." << std::endl;
    t1 = std::chrono::high_resolution_clock::now();
    barray.append(barray2);
    t2 = std::chrono::high_resolution_clock::now();
    
//    std::cout << "Time to append: " << ellapsed_time_s(t1, t2) * 1000.0 << " (ms)" << std::endl;
    
//    std::cout << "After append: ";
    
    for (uint32_t i = 0; i < sz; i++)
    {
        if (barray.at(i))
        {
            std::cout << i << std::endl;
        }
        assert(!barray.at(i));
    }
    
//    std::cout << "Ok" << std::endl;
    
    
    assert(barray.at(sz));
    assert(barray.at(sz+1));
//    assert(!barray.at(sz-2));
//    assert(!barray.at(sz+1));
    
    return ellapsed_time_s(t1, t2);
}

double test_keep(uint32_t sz)
{
    using namespace util;
    
    std::chrono::high_resolution_clock::time_point t1;
    std::chrono::high_resolution_clock::time_point t2;
    
    t1 = std::chrono::high_resolution_clock::now();
    
    bit_array barray(sz);
    barray.fill(false);
    
    barray.place(true, 10);
    barray.place(true, 12);
    barray.place(true, 14);
    
    dynamic_array<util::u64> at_indices(4);
    at_indices.place(10, 0);
    at_indices.place(12, 1);
    at_indices.place(14, 2);
    at_indices.place(15, 3);
    
    barray.unchecked_keep(at_indices);
    
    t2 = std::chrono::high_resolution_clock::now();
    
    assert(barray.size() == at_indices.tail());
    
    assert(barray.at(0));
    assert(barray.at(1));
    assert(barray.at(2));
    assert(!barray.at(3));
    
    bit_array barray2(barray.size());
    
    barray2.fill(false);
    
    barray2.place(true, 0);
    barray2.place(true, 1);
    barray2.place(true, 2);
    barray2.place(false, 3);
    
    bit_array::unchecked_dot_eq(barray, barray2, barray, 0, barray.size());
    
    assert(barray.all());
    
    return ellapsed_time_s(t1, t2);
}

void test_keep_multi(uint32_t n_iters)
{
    double mean = 0.0;
    double iters = 0.0;
    uint32_t sz = 1e5;
    
    for (uint32_t i = 0; i < n_iters; i++)
    {
        double res = test_keep(sz);
        mean = (mean * iters + res) / (iters + 1.0);
        iters += 1.0;
    }
    
    std::cout << "Mean time: (keep) " << (mean * 1000.0) << " (ms), ";
    std::cout << sz << " (elements)" << std::endl;
    std::cout << "--" << std::endl;
}

void test_thread2()
{
    uint32_t sz = 1e6;
    double mean = 0.0;
    double iters = 0.0;
    bool force_use_thread = false;
    uint32_t n_threads = 4;
    uint32_t max_iters = 1000;
    
    for (size_t i = 0; i < max_iters; i++)
    {
        double res = test_fast_threaded_access(sz, force_use_thread, n_threads);
        mean = (mean * iters + res) / (iters + 1.0);
        iters += 1.0;
    }
    
    std::cout << "Mean time: (dot or) " << (mean * 1000.0) << " (ms), ";
    std::cout << sz << " (elements)" << std::endl;
    std::cout << "--" << std::endl;
}

void test_threaded_accessor()
{
    using namespace util;
    using namespace std::chrono;
    
    int sz = (int) 1e8;
    
    bit_array barray(sz);
    bit_array barray2(barray);
    
    barray.fill(false);
    barray2.fill(true);
    
    high_resolution_clock::time_point t1 = high_resolution_clock::now();
    
    std::vector<std::thread> threads;
    
    uint32_t n_threads = 4;
    
    threads.reserve(n_threads);
    
    int thread_increment = (uint32_t) sz / (n_threads);
    
    uint32_t start = 0;
    uint32_t stop;
    
    for (size_t i = 0; i < n_threads; i++)
    {
        stop = start + thread_increment - 1;
        
        if (i == n_threads-1) stop += 1;
        
        std::cout << "start is: " << start << std::endl;
        std::cout << "stop is: " << stop << std::endl;
        
        std::thread t1(bit_array::unchecked_dot_or, std::ref(barray),
                       std::ref(barray2), std::ref(barray), start, stop);
        threads.push_back(std::move(t1));
        
        start += thread_increment;
    }
    
    for (auto& thread : threads)
    {
        thread.join();
    }
    
    high_resolution_clock::time_point t2 = high_resolution_clock::now();
    
    double ellapsed = ellapsed_time_s(t1, t2);
    
    std::cout << "Threaded dot or: " << ellapsed * 1000.0 << " (ms)" << std::endl;
    
    assert(barray.all());
    
    //  now non-threaded
    
    barray.fill(false);
    
    t1 = high_resolution_clock::now();
    
    bit_array::unchecked_dot_or(barray, barray2, barray, 0, barray.size());
    
    t2 = high_resolution_clock::now();
    
    ellapsed = ellapsed_time_s(t1, t2);
    
    std::cout << "Non-threaded dot or: " << ellapsed * 1000.0 << " (ms)" << std::endl;
}

double test_fast_threaded_access(uint32_t sz, bool force_use_thread, uint32_t n_threads)
{
    //  compare julia
    
    using namespace util;
    using namespace std::chrono;
    
    bool use_thread = force_use_thread || sz >= (uint32_t) 1e6;
    
    high_resolution_clock::time_point t1 = high_resolution_clock::now();
    
    bit_array x(sz);
    bit_array y(sz);
    
    x.fill(false);
    y.fill(true);
    
    if (use_thread)
    {
//        std::cout << "using thread" << std::endl;
        std::vector<std::thread> threads;
        threads.reserve(n_threads);
        int thread_increment = (uint32_t) sz / (n_threads);
        uint32_t start = 0;
        uint32_t stop;
        for (size_t i = 0; i < n_threads; i++)
        {
            stop = start + thread_increment - 1;
            if (i == n_threads-1) stop += 1;
            std::thread t1(bit_array::unchecked_dot_or, std::ref(x),
                           std::ref(x), std::ref(y), start, stop);
            threads.push_back(std::move(t1));
            start += thread_increment;
        }
    
        for (auto& thread : threads) thread.join();
    }
    else
    {
        bit_array::unchecked_dot_or(x, y, y, 0, x.size());
    }
    
    high_resolution_clock::time_point t2 = high_resolution_clock::now();
    
    double duration = ellapsed_time_s(t1, t2);
    
//    assert(bit_array::all(x));
    
//    std::cout << "Total time: " << (duration * 1000.0) << "(ms)" << std::endl;
    
    return duration;
}

double ellapsed_time_s(std::chrono::high_resolution_clock::time_point t1, std::chrono::high_resolution_clock::time_point t2)
{
    return std::chrono::duration_cast<std::chrono::duration<double>>(t2 - t1).count();
}

void test_bit_array_copy()
{
    using namespace util;
    using namespace std::chrono;
    
    int sz = (int) 1e8;
    
    high_resolution_clock::time_point t1 = high_resolution_clock::now();
    
    bit_array barray(sz);
    barray.fill(true);
    barray.place(false, 5);
    bit_array barray2 = barray;
    
    high_resolution_clock::time_point t2 = high_resolution_clock::now();
    
    duration<double> time_span = duration_cast<duration<double>>(t2 - t1);
    
    std::cout << "Copy time: " << time_span.count() * 1000 << "(ms)" << std::endl;
    
    assert(barray2.size() == barray.size());
    
    t1 = high_resolution_clock::now();
    
    for (size_t i = 0; i < sz; i++)
    {
        assert(barray2.at(i) == barray.at(i));
    }
    
    t2 = high_resolution_clock::now();
    time_span = duration_cast<duration<double>>(t2 - t1);
    
    std::cout << "Compare time: (loop) " << time_span.count() << "(s)" << std::endl;
    
    bit_array barray3(sz);
    barray3.fill(false);
    
    barray2.place(false, 100);
    
    assert(!barray2.at(100));
    assert(barray.at(100));
    
    t1 = high_resolution_clock::now();
    
    bit_array::unchecked_dot_or(barray3, barray3, barray2, 0, barray2.size());
    
    t2 = high_resolution_clock::now();
    time_span = duration_cast<duration<double>>(t2 - t1);
    std::cout << "Compare time: (dot or)" << time_span.count() * 1000 << "(ms)" << std::endl;
    
    barray2.fill(true);
}

void test_bit_array()
{
    using namespace util;
    using namespace std::chrono;
    
    int sz = 10001;
    
    bit_array barray(sz);
    
    barray.fill(true);
    
    for (int i = 0; i < barray.size(); i++)
    {
        assert(barray.at(i));
    }
    
    barray.unchecked_place(false, 88);
    
    assert(!barray.at(88));
    assert(barray.at(89));
    
    for (int i = 0; i < 204; i++)
    {
        barray.push(false);
        sz++;
    }
    
    barray.push(true);
    sz++;
    
    assert(sz == barray.size());
    
    assert(barray.at(sz-1));
    assert(!barray.at(sz-2));
    
    int sz2 = (int) 1e5;
    
    bit_array barray2(sz2);
    bit_array barray3(sz2);
    
    barray2.fill(false);
    barray3.fill(true);
    
    bit_array::unchecked_dot_or(barray2, barray2, barray3, 0, barray2.size());
    
    for (int i = 0; i < sz2; i++)
    {
        assert(barray2.at(i));
    }
    
    barray2.fill(false);
    
    bit_array::unchecked_dot_and(barray2, barray2, barray3, 0, barray2.size());
    
    for (int i = 0; i < sz2; i++)
    {
        assert(!barray2.at(i));
    }
    
    bit_array barray4(1e6);
    bit_array barray5(1e6);
    
    barray4.fill(false);
    barray5.fill(false);
    
    for (size_t i = 0; i < barray4.size(); i++)
    {
        barray4.unchecked_place(true, i);
        barray5.unchecked_place(true, i);
        
        assert(barray4.at(i) == barray5.at(i));
    }
    
    high_resolution_clock::time_point t1;
    high_resolution_clock::time_point t2;
    
    t1 = high_resolution_clock::now();
    barray4.all();
    t2 = high_resolution_clock::now();
    
    std::cout << "Total time (all): " << ellapsed_time_s(t1, t2) * 1000 << " (ms), ";
    std::cout << barray4.size() << " (elements)" << std::endl;
    std::cout << "--" << std::endl;
    
    bit_array::unchecked_dot_and(barray4, barray4, barray5, 0, barray4.size());
    
    barray4.place(true, barray4.size()-1);
    
    assert(barray4.all());
    
    uint32_t sz6 = 4;
    bit_array barray6(sz6);
    barray6.fill(false);
    
    for (size_t i = 0; i < barray6.size(); i++)
    {
        assert(!barray6.at(i));
    }
    
//    assert(!bit_array::all(barray6));
    
}

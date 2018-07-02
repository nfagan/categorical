//
//  allocators.hpp
//  locator
//
//  Created by Nick Fagan on 2/28/18.
//

#pragma once

#include "types.hpp"
#include <cstdint>
#include <new>
#include <cstring>
#include <cstdlib>
#include <type_traits>

namespace util {
    template<typename T>
    class trivial_allocator;
    
    template<typename T>
    class dynamic_allocator;
}

//
//  trivial allocator
//

template<typename T>
class util::trivial_allocator
{
public:
    trivial_allocator() = delete;
    ~trivial_allocator() = delete;
    
    trivial_allocator(const trivial_allocator& other) = delete;
    trivial_allocator& operator=(const trivial_allocator& other) = delete;
    trivial_allocator(trivial_allocator&& rhs) noexcept = delete;
    trivial_allocator& operator=(trivial_allocator&& other) noexcept = delete;
    
    static T* create(util::u64 with_size);
    static T* allocate(util::u64 with_size);
    static T* resize(T* data, util::u64 to_size, util::u64 original_size);
    static void copy(T* dest, T* source, util::u64 sz);
    static void dispose(T* data);
    
    constexpr static bool is_valid_alloc_t = std::is_trivially_copyable<T>::value;
};

template<typename T>
T* util::trivial_allocator<T>::create(util::u64 with_size)
{
    if (with_size == 0)
    {
        return nullptr;
    }
    
    return allocate(with_size);
}

template<typename T>
T* util::trivial_allocator<T>::resize(T* data, util::u64 to_size, util::u64 original_size)
{
    if (to_size == 0)
    {
        dispose(data);
        return nullptr;
    }
    
    size_t dest_size = to_size * sizeof(T);
    return (T*) std::realloc(data, dest_size);
}

template<typename T>
T* util::trivial_allocator<T>::allocate(util::u64 with_size)
{
    T* data = (T*) std::malloc(with_size * sizeof(T));
    
    if (data == nullptr)
    {
        throw std::bad_alloc();
    }
    
    return data;
}

template<typename T>
void util::trivial_allocator<T>::copy(T* dest, T* source, util::u64 sz)
{
    memcpy(dest, source, sz * sizeof(T));
}

template<typename T>
void util::trivial_allocator<T>::dispose(T* data)
{
    std::free(data);
}

//
//  dynamic allocator
//

template<typename T>
class util::dynamic_allocator
{
public:
    dynamic_allocator() = delete;
    ~dynamic_allocator() = delete;
    
    dynamic_allocator(const dynamic_allocator& other) = delete;
    dynamic_allocator& operator=(const dynamic_allocator& other) = delete;
    dynamic_allocator(dynamic_allocator&& rhs) noexcept = delete;
    dynamic_allocator& operator=(dynamic_allocator&& other) noexcept = delete;
    
    static T* create(util::u64 with_size);
    static T* allocate(util::u64 with_size);
    static T* resize(T* data, util::u64 to_size, util::u64 original_size);
    static void copy(T* dest, T* source, util::u64 sz);
    static void dispose(T* data);
    
    constexpr static bool is_valid_alloc_t = true;
};

template<typename T>
T* util::dynamic_allocator<T>::create(util::u64 with_size)
{
    if (with_size == 0)
    {
        return nullptr;
    }
    
    return allocate(with_size);
}

template<typename T>
T* util::dynamic_allocator<T>::resize(T* data, util::u64 to_size, util::u64 original_size)
{    
    T* new_data = allocate(to_size);
    
    util::u64 n_move = to_size > original_size ? original_size : to_size;
    
    for (util::u64 i = 0; i < n_move; i++)
    {
        new_data[i] = std::move(data[i]);
    }
    
    delete[] data;
    
    return new_data;
}

template<typename T>
T* util::dynamic_allocator<T>::allocate(util::u64 with_size)
{
    T* data = new T[with_size];
    
    if (data == nullptr)
    {
        throw std::bad_alloc();
    }
    
    return data;
}

template<typename T>
void util::dynamic_allocator<T>::dispose(T* data)
{
    delete[] data;
}

template<typename T>
void util::dynamic_allocator<T>::copy(T* dest, T* source, util::u64 sz)
{
    for (util::u64 i = 0; i < sz; i++)
    {
        dest[i] = source[i];
    }
}

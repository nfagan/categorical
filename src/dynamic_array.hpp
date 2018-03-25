//
//  dynamic_array.hpp
//  locator
//
//  Created by Nick Fagan on 2/15/18.
//

#pragma once

#include "allocators.hpp"
#include "types.hpp"
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <algorithm>
#include <cstdint>

namespace util
{
    template<typename T, typename A = util::trivial_allocator<T>>
    class dynamic_array;
}

template<typename T, typename A>
class util::dynamic_array
{
public:
    explicit dynamic_array(util::u64 initial_size);
    dynamic_array();
    ~dynamic_array() noexcept;
    
    dynamic_array(const dynamic_array& other);
    dynamic_array& operator=(const dynamic_array& other);
    dynamic_array(dynamic_array&& rhs) noexcept;
    dynamic_array& operator=(dynamic_array&& other) noexcept;
    
    T at(util::u64 index) const;
    T& ref_at(util::u64 index) const;
    
    void push(T element);
    void place(T element, util::u64 at_index);
    void erase(util::u64 at_index);
    void insert(T element, util::u64 at_index);
    void unchecked_place(T element, util::u64 at_index);
    
    bool eq_contents(const dynamic_array<T, A>& other) const;
    
    void seek_tail_to_end();
    void seek_tail_to_start();
    
    T* unsafe_get_pointer() const;
    
    void resize(util::u64 to_size);
    void clear();
    
    void sort();
    void unchecked_sort(util::u64 end);
    
    util::u64 size() const;
    util::u64 tail() const;
private:
    T* m_elements;
    util::u64 m_size;
    util::u64 m_tail;
    
    void dispose();
    
    static util::u64 get_next_size_larger(util::u64 current_size);
};

//
//  impl
//

template<typename T, typename A>
util::dynamic_array<T, A>::dynamic_array(util::u64 initial_size)
{
    static_assert(A::is_valid_alloc_t, "Type does not meet allocator requirements.");
    m_tail = initial_size;
    m_size = initial_size;
    m_elements = A::create(initial_size);
}

template<typename T, typename A>
util::dynamic_array<T, A>::dynamic_array()
{
    static_assert(A::is_valid_alloc_t, "Type does not meet allocator requirements.");
    m_size = 0;
    m_tail = 0;
    m_elements = nullptr;
}

//  copy-construct
template<typename T, typename A>
util::dynamic_array<T, A>::dynamic_array(const util::dynamic_array<T, A>& other)
{
    if (other.m_size > 0)
    {
        m_elements = A::create(other.m_size);
        A::copy(m_elements, other.m_elements, other.m_size);
    }
    else
    {
        m_elements = nullptr;
    }
    
    m_size = other.m_size;
    m_tail = other.m_tail;
}

//  copy-assign
template<typename T, typename A>
util::dynamic_array<T, A>& util::dynamic_array<T, A>::operator=(const util::dynamic_array<T, A>& other)
{
    util::dynamic_array<T, A> tmp(other);
    *this = std::move(tmp);
    return *this;
}

//  move-construct
template<typename T, typename A>
util::dynamic_array<T, A>::dynamic_array(util::dynamic_array<T, A>&& rhs) noexcept
{
    m_elements = rhs.m_elements;
    m_size = rhs.m_size;
    m_tail = rhs.m_tail;
    
    rhs.m_size = 0;
    rhs.m_tail = 0;
    rhs.m_elements = nullptr;
}

//  move-assign
template<typename T, typename A>
util::dynamic_array<T, A>& util::dynamic_array<T, A>::operator=(util::dynamic_array<T, A>&& rhs) noexcept
{
    dispose();
    
    m_elements = rhs.m_elements;
    m_size = rhs.m_size;
    m_tail = rhs.m_tail;
    
    rhs.m_size = 0;
    rhs.m_tail = 0;
    rhs.m_elements = nullptr;
    
    return *this;
}

template<typename T, typename A>
util::dynamic_array<T, A>::~dynamic_array() noexcept
{
    dispose();
}

template<typename T, typename A>
T util::dynamic_array<T, A>::at(util::u64 index) const
{
    return m_elements[index];
}

template<typename T, typename A>
T& util::dynamic_array<T, A>::ref_at(util::u64 index) const
{
    return m_elements[index];
}

template<typename T, typename A>
void util::dynamic_array<T, A>::dispose()
{
    A::dispose(m_elements);
    m_size = 0;
    m_tail = 0;
    m_elements = nullptr;
}

template<typename T, typename A>
void util::dynamic_array<T, A>::clear()
{
    dispose();
}

template<typename T, typename A>
void util::dynamic_array<T, A>::resize(util::u64 to_size)
{
    size_t dest_size = to_size * sizeof(T);
    
    if (m_elements != nullptr)
    {
        m_elements = A::resize(m_elements, dest_size, m_size);
    }
    else
    {
        m_elements = A::create(to_size);
    }
    
    if (to_size < m_tail)
    {
        m_tail = to_size;
    }
    
    m_size = to_size;
}

template<typename T, typename A>
util::u64 util::dynamic_array<T, A>::size() const
{
    return m_size;
}

template<typename T, typename A>
util::u64 util::dynamic_array<T, A>::tail() const
{
    return m_tail;
}

template<typename T, typename A>
void util::dynamic_array<T, A>::push(T element)
{
    if (m_tail == m_size)
    {
        resize(get_next_size_larger(m_size));
    }
    
    m_elements[m_tail] = element;
    
    m_tail++;
}

template<typename T, typename A>
util::u64 util::dynamic_array<T, A>::get_next_size_larger(util::u64 current_size)
{
    return current_size == 0 ? 1 : current_size * 2;
}

template<typename T, typename A>
void util::dynamic_array<T, A>::place(T element, util::u64 at_index)
{
    if (m_size == 0 || at_index > m_size)
    {
        throw std::runtime_error("Index exceeds array size.");
    }
    
    m_elements[at_index] = element;
}

template<typename T, typename A>
void util::dynamic_array<T, A>::insert(T element, util::u64 at_index)
{
    util::u64 orig_tail = m_tail;
    
    //  if inserting outside the original array bounds,
    //  resize to `at_index` * 2, and point tail to `at_index`.
    if (at_index >= m_size)
    {
        resize(get_next_size_larger(at_index));
        m_tail = at_index + 1;
    }
    else if (orig_tail == m_size)
    {
        resize(get_next_size_larger(m_size));
        m_tail = orig_tail + 1;
    }
    else
    {
        m_tail++;
    }
    
    util::u64 i = orig_tail;
    
    while (i > at_index)
    {
        m_elements[i] = std::move(m_elements[i-1]);
        i--;
    }
    
    m_elements[at_index] = element;
}

template<typename T, typename A>
void util::dynamic_array<T, A>::erase(util::u64 at_index)
{
    for (util::u64 i = at_index; i < m_tail-1; i++)
    {
        m_elements[i] = std::move(m_elements[i+1]);
    }
    
    if (m_tail > 0)
    {
        m_tail--;
    }
}

template<typename T, typename A>
bool util::dynamic_array<T, A>::eq_contents(const util::dynamic_array<T, A>& other) const
{
    if (m_tail != other.m_tail)
    {
        return false;
    }
    
    for (util::u64 i = 0; i < m_tail; i++)
    {
        if (m_elements[i] != other.m_elements[i])
        {
            return false;
        }
    }
    
    return true;
}

template<typename T, typename A>
void util::dynamic_array<T, A>::unchecked_place(T element, util::u64 at_index)
{    
    m_elements[at_index] = element;
}

template<typename T, typename A>
T* util::dynamic_array<T, A>::unsafe_get_pointer() const
{
    return m_elements;
}

template<typename T, typename A>
void util::dynamic_array<T, A>::seek_tail_to_end()
{
    m_tail = m_size;
}

template<typename T, typename A>
void util::dynamic_array<T, A>::seek_tail_to_start()
{
    m_tail = 0;
}

template<typename T, typename A>
void util::dynamic_array<T, A>::unchecked_sort(util::u64 end)
{
    std::sort(m_elements, m_elements + end);
}

template<typename T, typename A>
void util::dynamic_array<T, A>::sort()
{
    std::sort(m_elements, m_elements + m_tail);
}

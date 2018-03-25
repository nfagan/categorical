//
//  bit_array.cpp
//  bit_matrix
//
//  Created by Nick Fagan on 2/17/18.
//

#include "bit_array.hpp"
#include <stdexcept>
#include <cstring>
#include <cmath>

util::bit_array::bit_array()
{
    m_size = 0;
    m_size_int = get_size_int();
}

util::bit_array::bit_array(util::u64 size)
{
    m_size = size;
    m_size_int = get_size_int();
    m_data.resize(get_data_size(size));
    m_data.seek_tail_to_end();
}

util::bit_array::bit_array(util::u64 size, bool fill_with)
{
    m_size = size;
    m_size_int = get_size_int();
    m_data.resize(get_data_size(size));
    m_data.seek_tail_to_end();
    fill(fill_with);
}

util::bit_array::~bit_array() noexcept
{
    //
}

//  copy-construct
util::bit_array::bit_array(const util::bit_array& other) : m_data(other.m_data)
{
    m_size = other.m_size;
    m_size_int = other.m_size_int;
}

//  copy-assign
util::bit_array& util::bit_array::operator=(const util::bit_array& other)
{
    util::bit_array tmp(other);
    *this = std::move(tmp);
    return *this;
}

//  move-construct
util::bit_array::bit_array(util::bit_array&& rhs) noexcept :
    m_data(std::move(rhs.m_data))
{
    m_size = rhs.m_size;
    m_size_int = rhs.m_size_int;
    
    rhs.m_size = 0;
}

//  move-assign
util::bit_array& util::bit_array::operator=(util::bit_array&& rhs) noexcept
{
    m_data = std::move(rhs.m_data);
    m_size = rhs.m_size;
    m_size_int = rhs.m_size_int;
    
    rhs.m_size = 0;
    
    return *this;
}

void util::bit_array::push(bool value)
{
    util::u64 bin = get_bin(m_size);
    util::u32 bit = get_bit(m_size);
    
    if (bit == 0)
    {
        m_data.push(0u);
    }
    
    unchecked_place(value, bin, bit);
    
    m_size++;
}

void util::bit_array::place(bool value, util::u64 at_index)
{
    if (at_index > m_size-1)
    {
        throw std::runtime_error("Index exceeds array dimensions.");
    }
    
    unchecked_place(value, at_index);
}

void util::bit_array::unchecked_place(bool value, util::u64 at_index)
{
    util::u64 bin = get_bin(at_index);
    util::u32 bit = get_bit(at_index);
    
    unchecked_place(value, bin, bit);
}

void util::bit_array::unchecked_place(bool value, util::u64 bin, util::u32 bit)
{
    util::u32* data = m_data.unsafe_get_pointer();
    util::u32 current = data[bin];
    
    if (value)
    {
        current = current | (1u << bit);
    }
    else
    {
        current = current & ~(1u << bit);
    }
    
    data[bin] = current;
}

void util::bit_array::keep(const util::dynamic_array<util::u64>& at_indices)
{
    for (util::u64 i = 0; i < at_indices.tail(); i++)
    {
        if (at_indices.at(i) >= m_size)
        {
            throw std::runtime_error("Index exceeds array dimensions.");
        }
    }
    
    unchecked_keep(at_indices);
}

void util::bit_array::empty()
{
    m_data.clear();
    m_size = 0;
}

void util::bit_array::unchecked_keep(const util::dynamic_array<util::u64> &at_indices, util::u64 index_offset)
{
    util::u64 new_size = at_indices.tail();
    
    if (new_size == 0)
    {
        empty();
        return;
    }
    
    util::u64 new_data_size = get_data_size(new_size);
    
    util::dynamic_array<util::u32> tmp(new_data_size);
    
    util::u32* tmp_ptr = tmp.unsafe_get_pointer();
    util::u32* data_ptr = m_data.unsafe_get_pointer();
    util::u64* at_indices_ptr = at_indices.unsafe_get_pointer();
    
    std::memset(tmp_ptr, 0u, new_data_size * sizeof(util::u32));
    
    for (util::u64 i = 0; i < new_size; i++)
    {
        util::u64 idx = at_indices_ptr[i] + index_offset;
        util::u32 datum = data_ptr[get_bin(idx)];
        util::u32 bit = get_bit(idx);
        util::u64 into_bin = get_bin(i);
        util::u32 into_bit = get_bit(i);
        
        bool res = datum & (1u << bit);
        
        if (res)
        {
            tmp_ptr[into_bin] |= (1u << into_bit);
        }
    }
    
    m_data = std::move(tmp);
    m_size = new_size;
}

bool util::bit_array::assign_true(const util::u64* at_indices_data, util::u64 indices_sz, util::s64 index_offset)
{
    util::u32* own_data = m_data.unsafe_get_pointer();
    
    for (util::u64 i = 0; i < indices_sz; i++)
    {
        util::u64 idx = at_indices_data[i] + index_offset;
        
        if (idx >= m_size)
        {
            return false;
        }
        
        util::u64 bin = get_bin(idx);
        util::u32 bit = get_bit(idx);
        
        own_data[bin] |= (1u << bit);
    }
    
    return true;
}

bool util::bit_array::assign_true(const util::dynamic_array<util::u64>& at_indices, util::s64 index_offset)
{
    const util::u64* at_indices_data = at_indices.unsafe_get_pointer();
    util::u64 indices_size = at_indices.tail();
    
    return assign_true(at_indices_data, indices_size, index_offset);
}

bool util::bit_array::assign_true(const std::vector<util::u64>& at_indices, util::s64 index_offset)
{
    const util::u64* at_indices_data = at_indices.data();
    util::u64 indices_size = at_indices.size();
    
    return assign_true(at_indices_data, indices_size, index_offset);
}


void util::bit_array::unchecked_assign_true(const util::dynamic_array<util::u64> &at_indices, util::s64 index_offset)
{
    util::u64* at_indices_data = at_indices.unsafe_get_pointer();
    util::u32* own_data = m_data.unsafe_get_pointer();
    util::u64 indices_size = at_indices.tail();
    
    for (util::u64 i = 0; i < indices_size; i++)
    {
        util::u64 idx = at_indices_data[i] + index_offset;
        util::u64 bin = get_bin(idx);
        util::u32 bit = get_bit(idx);
        
        own_data[bin] |= (1u << bit);
    }
}

void util::bit_array::append(const util::bit_array &other)
{
    if (other.m_size == 0)
    {
        return;
    }
    
    if (m_size == 0)
    {
        *this = other;
        return;
    }
    
    util::u64 other_orig_data_size = other.m_data.size();
    util::u64 orig_data_size = m_data.size();
    util::u64 new_data_size = orig_data_size + other_orig_data_size;
    util::u64 orig_size = m_size;
    
    m_data.resize(new_data_size);
    
    util::u32* m_data_ptr = m_data.unsafe_get_pointer();
    util::u32* other_data_ptr = other.m_data.unsafe_get_pointer();
    
    util::u32 last_bit = get_bit(orig_size);
    
    util::u64 orig_tail = get_data_size(orig_size);
    util::u64 other_tail = get_data_size(other.m_size);
    
    m_size += other.m_size;
    
    //  fast copy of elements if they're already aligned.
    if (last_bit == 0)
    {
        std::memcpy(&m_data_ptr[orig_tail], other_data_ptr, other_tail * sizeof(util::u32));
        return;
    }
    
    std::memset(&m_data_ptr[orig_tail], 0u, other_tail * sizeof(util::u32));
    
    util::u32 bit_offset = m_size_int - last_bit;
    
    //  fill remaining elements in final bin with 0
    util::u32 last_bin0 = ~(0u) >> bit_offset;
    
    m_data_ptr[orig_tail-1] &= last_bin0;

    for (util::u64 i = 0; i < other_tail; i++)
    {
        util::u32 other0 = other_data_ptr[i];
        util::u32 other1 = other0;

        other0 = other0 << last_bit;
        other1 = other1 >> bit_offset;

        m_data_ptr[orig_tail + i - 1] |= other0;
        m_data_ptr[orig_tail + i] |= other1;
    }
}

void util::bit_array::fill(bool with)
{
    util::u32 fill_with = with ? ~(0u) : 0u;
    util::u64 fill_to = get_data_size(m_size);
    std::memset(m_data.unsafe_get_pointer(), fill_with, fill_to * sizeof(util::u32));
}

void util::bit_array::flip()
{
    util::u64 data_size = get_data_size(m_size);
    util::u32* data = m_data.unsafe_get_pointer();
    
    for (util::u64 i = 0; i < data_size; i++)
    {
        data[i] = ~(data[i]);
    }
}

bool util::bit_array::at(util::u64 index) const
{
    util::u64 bin = get_bin(index);
    util::u32 bit = get_bit(index);
    
    return m_data.at(bin) & (1 << bit);
}

util::u64 util::bit_array::sum() const
{
    
    if (m_size == 0)
    {
        return 0u;
    }
    
    util::u64 c_sum = 0;
    util::u64 data_size = get_data_size(m_size);
    util::u32* data = m_data.unsafe_get_pointer();
    
    for (util::u64 i = 0; i < data_size-1; i++)
    {
        c_sum += util::bit_array::bit_sum(data[i]);
    }
    
    //  only sum the active values in the final bin
    util::u32 last_datum = get_final_bin_with_zeros(data, data_size);
    
    c_sum += util::bit_array::bit_sum(last_datum);
    
    return c_sum;
}

void util::bit_array::resize(util::u64 to_size)
{
    if (to_size == m_size)
    {
        return;
    }
    
    util::u64 c_data_size = get_data_size(m_size);
    util::u64 new_data_size = get_data_size(to_size);
    util::u64 orig_size = m_size;
    
    util::u32* data = m_data.unsafe_get_pointer();
    
    if (c_data_size > 0)
    {
        data[c_data_size-1] = get_final_bin_with_zeros(data, c_data_size);
    }
    
    m_size = to_size;
    
    if (new_data_size == c_data_size)
    {
        return;
    }
    
    m_data.resize(new_data_size);
    
    if (to_size < orig_size)
    {
        return;
    }
    
    data = m_data.unsafe_get_pointer();
    
    util::u64 n_set = new_data_size - c_data_size;
    
    std::memset(data + c_data_size, 0u, n_set * sizeof(util::u32));
}

util::u64 util::bit_array::size() const
{
    return m_size;
}

util::u64 util::bit_array::get_bin(util::u64 index) const
{
    return index / m_size_int;
}

util::u32 util::bit_array::get_bit(util::u64 index) const
{
    return index % m_size_int;
}

util::u32 util::bit_array::get_final_bin_with_zeros() const
{
    util::u64 data_size = get_data_size(m_size);
    util::u32* data = m_data.unsafe_get_pointer();
    
    return get_final_bin_with_zeros(data, data_size);
}

util::u32 util::bit_array::get_final_bin_with_zeros(util::u32* data, util::u64 data_size) const
{
    util::u32 bit_offset = m_size_int - get_bit(m_size);
    
    util::u32 last_bin0 = ~(0u) >> bit_offset;
    util::u32 last_datum = data[data_size-1];
    
    last_datum &= last_bin0;
    
    return last_datum;
}

util::u64 util::bit_array::get_data_size(util::u64 n_elements) const
{
    double res = double(n_elements) / double(m_size_int);
    return util::u64(std::ceil(res));
}

util::u32 util::bit_array::get_size_int() const
{
    return sizeof(util::u32) * 8u;
}

bool util::bit_array::all_bits_set(util::u32 value, util::u32 n)
{
    util::u32 mask = (1 << n) - 1;
    value &= mask;
    return value == mask;
}

util::u32 util::bit_array::bit_sum(util::u32 i)
{
    //  https://stackoverflow.com/questions/109023/how-to-count-the-number-of-set-bits-in-a-32-bit-integer
    i = i - ((i >> 1) & 0x55555555);
    i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
    return (((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;
}

void util::bit_array::unchecked_dot_or(util::bit_array &out,
                                       const util::bit_array &a,
                                       const util::bit_array &b,
                                       util::u64 start,
                                       util::u64 stop)
{
    util::u64 first_bin = a.get_bin(start);
    util::u32 last_bit = a.get_bit(stop);
    util::u64 last_bin = last_bit == 0u ? a.get_bin(stop-1) : a.get_bin(stop);
    
    util::u32* a_data = a.m_data.unsafe_get_pointer();
    util::u32* b_data = b.m_data.unsafe_get_pointer();
    util::u32* out_data = out.m_data.unsafe_get_pointer();
    
    for (util::u64 i = first_bin; i <= last_bin; i++)
    {
        out_data[i] = a_data[i] | b_data[i];
    }
}

void util::bit_array::unchecked_dot_and(util::bit_array &out,
                                        const util::bit_array &a,
                                        const util::bit_array &b,
                                        util::u64 start,
                                        util::u64 stop)
{
    util::u64 first_bin = a.get_bin(start);
    util::u32 last_bit = a.get_bit(stop);
    util::u64 last_bin = last_bit == 0u ? a.get_bin(stop-1) : a.get_bin(stop);
    
    util::u32* a_data = a.m_data.unsafe_get_pointer();
    util::u32* b_data = b.m_data.unsafe_get_pointer();
    util::u32* out_data = out.m_data.unsafe_get_pointer();
    
    for (util::u64 i = first_bin; i <= last_bin; i++)
    {
        out_data[i] = a_data[i] & b_data[i];
    }
}

void util::bit_array::unchecked_dot_and_not(util::bit_array &out,
                                        const util::bit_array &a,
                                        const util::bit_array &b,
                                        util::u64 start,
                                        util::u64 stop)
{
    util::u64 first_bin = a.get_bin(start);
    util::u32 last_bit = a.get_bit(stop);
    util::u64 last_bin = last_bit == 0u ? a.get_bin(stop-1) : a.get_bin(stop);
    
    util::u32* a_data = a.m_data.unsafe_get_pointer();
    util::u32* b_data = b.m_data.unsafe_get_pointer();
    util::u32* out_data = out.m_data.unsafe_get_pointer();
    
    for (util::u64 i = first_bin; i <= last_bin; i++)
    {
        out_data[i] = a_data[i] & ~(b_data[i]);
    }
}

void util::bit_array::unchecked_dot_eq(util::bit_array &out,
                                        const util::bit_array &a,
                                        const util::bit_array &b,
                                        util::u64 start,
                                        util::u64 stop)
{
    util::u64 first_bin = a.get_bin(start);
    util::u32 last_bit = a.get_bit(stop);
    util::u64 last_bin = last_bit == 0u ? a.get_bin(stop-1) : a.get_bin(stop);
    
    util::u32* a_data = a.m_data.unsafe_get_pointer();
    util::u32* b_data = b.m_data.unsafe_get_pointer();
    util::u32* out_data = out.m_data.unsafe_get_pointer();
    
    for (util::u64 i = first_bin; i <= last_bin; i++)
    {
        out_data[i] = ~(a_data[i] ^ b_data[i]);
    }
}

void util::bit_array::dot_or(util::bit_array &out,
                             const util::bit_array &a,
                             const util::bit_array &b)
{
    binary_check_dimensions(out, a, b);
    unchecked_dot_or(out, a, b, 0, a.m_size);
}

void util::bit_array::dot_and(util::bit_array &out,
                             const util::bit_array &a,
                             const util::bit_array &b)
{
    binary_check_dimensions(out, a, b);
    unchecked_dot_and(out, a, b, 0, a.m_size);
}

bool util::bit_array::all() const
{
    if (m_size == 0)
    {
        return false;
    }
    
    util::u64 last_bin = get_bin(m_size);
    util::u32 last_bit = get_bit(m_size);

    util::u32* a_data = m_data.unsafe_get_pointer();

    util::u64 stop_idx = last_bit == 0u ? last_bin-1 : last_bin;
    util::u32 n_check_last = last_bit == 0u ? m_size_int : last_bit;
    util::u32 one = ~(0u);
    
    for (util::u64 i = 0; i < stop_idx; i++)
    {
        if (a_data[i] != one)
        {
            return false;
        }
    }
    
    util::u32 last_datum = get_final_bin_with_zeros(a_data, get_data_size(m_size));
    
    return util::bit_array::bit_sum(last_datum) == n_check_last;
}

bool util::bit_array::any() const
{
    if (m_size == 0)
    {
        return false;
    }
    
    util::u32* a_data = m_data.unsafe_get_pointer();
    util::u64 data_size = get_data_size(m_size);
    
    for (util::u64 i = 0; i < data_size-1; i++)
    {
        if (a_data[i] != 0u)
        {
            return true;
        }
    }
    
    //  make sure the bits beyond `m_size` are zeroed
    util::u32 last_datum = get_final_bin_with_zeros(a_data, data_size);
    
    return last_datum != 0u;
}

void util::bit_array::binary_check_dimensions(const util::bit_array &out,
                                              const util::bit_array &a,
                                              const util::bit_array &b)
{
    if (a.size() != b.size() || a.size() != out.size())
    {
        throw std::runtime_error("Dimension mismatch.");
    }
}

void util::bit_array::unchecked_find(util::u64* out, const util::bit_array& a, util::u64 index_offset)
{
    util::u64 data_size = a.get_data_size(a.m_size);
    util::u32 last_bit = a.get_bit(a.m_size);
    util::u32* data = a.m_data.unsafe_get_pointer();
    util::u32 size_int = a.m_size_int;
    util::u64 out_idx = 0;
    
    for (util::u64 i = 0; i < data_size; i++)
    {
        util::u32 datum = data[i];
        
        if (datum == 0u)
        {
            continue;
        }
        
        util::u32 stop_bit;
        
        if (i < data_size - 1)
        {
            stop_bit = a.m_size_int;
        }
        else
        {
            stop_bit = last_bit == 0 ? a.m_size_int : last_bit;
        }
        
        for (util::u32 j = 0; j < stop_bit; j++)
        {
            if (datum & (1u << j))
            {
                out[out_idx] = (i * size_int) + j + index_offset;
                out_idx++;
            }
        }
    }
}

util::dynamic_array<util::u64> util::bit_array::find(const util::bit_array &a, util::u64 index_offset)
{
    util::u64 n_true = a.sum();
    
    util::dynamic_array<util::u64> result(n_true);
    
    if (n_true == 0)
    {
        return result;
    }
    
    util::u64* result_ptr = result.unsafe_get_pointer();
    
    unchecked_find(result_ptr, a, index_offset);
    
    return result;
}

std::vector<util::u64> util::bit_array::findv(const util::bit_array& a, util::u64 index_offset)
{
    util::u64 n_true = a.sum();
    
    std::vector<util::u64> result(n_true);
    
    if (n_true == 0)
    {
        return result;
    }
    
    util::u64* result_ptr = result.data();
    
    unchecked_find(result_ptr, a, index_offset);
    
    return result;
}

util::bit_array::iterator util::bit_array::begin() const
{
    return util::bit_array::iterator(this);
}

//  iterator

util::bit_array::iterator::iterator(const util::bit_array* barray)
{
    m_idx = 0;
    m_bin = 0;
    m_bit = 0;
    m_size_int = barray->m_size_int;
    m_data = barray->m_data.unsafe_get_pointer();
}

void util::bit_array::iterator::next()
{
    if (++m_bit == m_size_int)
    {
        m_bit = 0;
        m_bin++;
    }
    
    m_idx++;
}

bool util::bit_array::iterator::value() const
{
    return m_data[m_bin] & (1u << m_bit);
}

void util::bit_array::iterator::set(bool value)
{
    util::u32 val = 1u << m_bit;
    
    if (value)
    {
        m_data[m_bin] |= val;
    }
    else
    {
        m_data[m_bin] &= ~val;
    }
}



//
//  bit_array.hpp
//  bit_matrix
//
//  Created by Nick Fagan on 2/17/18.
//

#pragma once

#include "types.hpp"
#include "dynamic_array.hpp"
#include <cstdint>
#include <vector>

namespace util {
    class bit_array;
}

class util::bit_array
{
public:
    struct iterator
    {
        iterator(const bit_array* barray);
        void next();
        bool value() const;
        void set(bool value);
    private:
        util::u32* m_data;
        util::u64 m_idx;
        util::u64 m_bin;
        util::u32 m_bit;
        util::u32 m_size_int;
    };
    
    explicit bit_array();
    explicit bit_array(util::u64 size);
    explicit bit_array(util::u64 size, bool fill_with);
    ~bit_array() noexcept;
    
    bit_array(const bit_array& other);
    bit_array& operator=(const bit_array& other);
    bit_array(bit_array&& rhs) noexcept;
    bit_array& operator=(bit_array&& other) noexcept;
    
    bit_array::iterator begin() const;
    
    util::u64 size() const;
    util::u64 sum() const;
    
    void resize(util::u64 to_size);
    
    void push(bool value);
    void place(bool value, util::u64 at_index);
    void unchecked_place(bool value, util::u64 at_index);
    void append(const bit_array &other);
    void keep(const util::dynamic_array<util::u64> &at_indices);
    void unchecked_keep(const util::dynamic_array<util::u64> &at_indices, util::u64 index_offset = 0);
    
    bool assign_true(const util::dynamic_array<util::u64> &at_indices, util::s64 index_offset = 0);
    bool assign_true(const std::vector<util::u64> &at_indices, util::s64 index_offset = 0);
    void unchecked_assign_true(const util::dynamic_array<util::u64> &at_indices, util::s64 index_offset = 0);
    
    bool at(util::u64 index) const;
    
    void fill(bool value);
    void empty();
    
    void flip();
    
    bool all() const;
    bool any() const;
    
    static void dot_or(bit_array& out, const bit_array& a, const bit_array& b);
    static void dot_and(bit_array& out, const bit_array& a, const bit_array& b);
    static void unchecked_dot_or(bit_array& out, const bit_array& a,
                                 const bit_array& b, util::u64 start, util::u64 stop);
    static void unchecked_dot_and(bit_array& out, const bit_array& a,
                                  const bit_array& b, util::u64 start, util::u64 stop);
    static void unchecked_dot_and_not(bit_array& out, const bit_array& a,
                                  const bit_array& b, util::u64 start, util::u64 stop);
    static void unchecked_dot_eq(bit_array& out, const bit_array& a,
                                  const bit_array& b, util::u64 start, util::u64 stop);
    
    static util::dynamic_array<util::u64> find(const bit_array& a, util::u64 index_offset = 0u);
    static std::vector<util::u64> findv(const bit_array& a, util::u64 index_offset = 0u);
    
private:
    util::dynamic_array<util::u32> m_data;
    
    util::u64 m_size;
    util::u32 m_size_int;
    
    util::u64 get_bin(util::u64 index) const;
    util::u32 get_bit(util::u64 index) const;
    util::u64 get_data_size(util::u64 n_elements) const;
    util::u32 get_final_bin_with_zeros() const;
    util::u32 get_final_bin_with_zeros(util::u32* data, util::u64 data_size) const;
    util::u32 get_size_int() const;
    
    bool assign_true(const util::u64* at_indices_data, util::u64 at_indices_sz, util::s64 index_offset);
    
    void unchecked_place(bool value, util::u64 bin, util::u32 bit);
    
    static void unchecked_find(util::u64* out, const bit_array& a, util::u64 index_offset);
    
    static void binary_check_dimensions(const bit_array& out, const bit_array& a, const bit_array& b);
    static bool all_bits_set(util::u32 value, util::u32 n);
    static util::u32 bit_sum(util::u32 i);
};

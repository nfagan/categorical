//
//  hashing.hpp
//  bit_array-test
//
//  Created by Nick Fagan on 11/8/19.
//

#pragma once

#include "types.hpp"
#include "platform.hpp"
#include <vector>
#include <type_traits>
#include <cstring>
#include <cassert>

#define TEMPLATE_HEADER template <typename K, typename V, typename Hash>
#define TEMPLATE_PREFIX util::IntegralTypeRowMap<K, V, Hash>

namespace util
{
    template <typename K, typename V, typename Hash>
    class IntegralTypeRowMap;
}

TEMPLATE_HEADER
class util::IntegralTypeRowMap
{
public:
    using key_bucket_t = std::vector<K>;
    using value_bucket_t = std::vector<V>;
    
    struct find_result
    {
        friend class util::IntegralTypeRowMap<K, V, Hash>;
        
        find_result(std::size_t bucket_index, const V* value) : bucket_index(bucket_index), value(value)
        {
            //
        }
        
        ~find_result() = default;
        
    private:
        std::size_t bucket_index;
        
    public:
        const V* value;
    };
    
public:
    IntegralTypeRowMap(const std::size_t num_buckets, const std::size_t num_columns);
    ~IntegralTypeRowMap() = default;
    
    const find_result find(const K* key_row) const;
    void insert(const find_result& result, const K* key_row, V value);
    std::size_t max_bucket_size() const;
    
private:
    const std::size_t num_buckets;
    const std::size_t num_columns;
    
    std::vector<key_bucket_t> keys;
    std::vector<value_bucket_t> values;
};

TEMPLATE_HEADER
TEMPLATE_PREFIX::IntegralTypeRowMap(const std::size_t num_buckets, const std::size_t num_columns) :
num_buckets(num_buckets), num_columns(num_columns)
{
#ifdef CAT_HAS_TRIVIALLY_COPYABLE
    static_assert(std::is_trivially_copyable<K>::value, "Key type must be trivially copyable.");
    static_assert(std::is_trivially_copyable<V>::value, "Value type must be trivially copyable.");
#endif
    
    keys.resize(num_buckets);
    values.resize(num_buckets);
}

TEMPLATE_HEADER
const typename TEMPLATE_PREFIX::find_result TEMPLATE_PREFIX::find(const K* key_row) const
{
    const std::size_t bucket_index = Hash{}(key_row, num_columns) % num_buckets;
    assert(bucket_index < keys.size());
    
    const value_bucket_t& value_bucket = values[bucket_index];
    const key_bucket_t& key_bucket = keys[bucket_index];
    const K* key_data = key_bucket.data();

    const std::size_t num_sequences = value_bucket.size();
    const std::size_t stride = num_columns * sizeof(K);
    
    for (std::size_t i = 0; i < num_sequences; i++)
    {
        if (std::memcmp(key_row, key_data + i * num_columns, stride) == 0)
        {
            return find_result(bucket_index, &value_bucket[i]);
        }
    }
    
    return find_result(bucket_index, nullptr);
}

TEMPLATE_HEADER
void TEMPLATE_PREFIX::insert(const typename TEMPLATE_PREFIX::find_result& result, const K* key_row, V value)
{
    assert(result.bucket_index < keys.size());
    
    key_bucket_t& key_bucket = keys[result.bucket_index];
    value_bucket_t& value_bucket = values[result.bucket_index];

    const std::size_t old_size = key_bucket.size();
    const std::size_t new_size = old_size + num_columns;

    assert(old_size / num_columns == value_bucket.size());

    key_bucket.resize(new_size);
    std::memcpy(key_bucket.data() + old_size, key_row, num_columns * sizeof(K));
    value_bucket.push_back(value);
}

TEMPLATE_HEADER
std::size_t TEMPLATE_PREFIX::max_bucket_size() const
{
    std::size_t max = 0;
    
    for (std::size_t i = 0; i < num_buckets; i++)
    {
        if (values[i].size() > max)
        {
            max = values[i].size();
        }
    }
    
    return max;
}

#undef TEMPLATE_PREFIX
#undef TEMPLATE_HEADER


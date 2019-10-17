//
//  multimap.hpp
//  bit_array-test
//
//  Created by Nick Fagan on 3/12/18.
//

#pragma once

#include <unordered_map>
#include <stdexcept>
#include <vector>
#include <cstdint>

namespace util {
    template<typename K, typename V>
    class multimap;
}

template<typename K, typename V>
class util::multimap
{
public:
    multimap() = default;
    ~multimap() = default;
    
    multimap(const util::multimap<K, V>& other);
    multimap(multimap&& rhs) noexcept;
    
    multimap& operator=(const multimap& other);
    multimap& operator=(multimap&& rhs) noexcept;
    
    auto find(const K& key) const;
    auto find(const V& key) const;
    
    auto endk() const;
    auto endv() const;
    
    std::vector<K> keys() const;
    std::vector<V> values() const;
    
    V at(const K& key) const;
    K at(const V& key) const;
    
    const V& ref_at(const K& key) const;
    const K& ref_at(const V& key) const;
    
    size_t erase(K key);
    size_t erase(V key);
    
    size_t size() const;
    
    bool contains(const K& key) const;
    bool contains(const V& key) const;
    
    void insert(K key, V value);
private:
    std::unordered_map<K, V> m_kv;
    std::unordered_map<V, K> m_vk;
};

//
//  impl
//


template<typename K, typename V>
util::multimap<K, V>::multimap(const util::multimap<K, V>& rhs) :
    m_kv(rhs.m_kv),
    m_vk(rhs.m_vk)
{
    //
}

template<typename K, typename V>
util::multimap<K, V>& util::multimap<K, V>::operator=(const util::multimap<K, V>& rhs)
{
    util::multimap<K, V> tmp(rhs);
    *this = std::move(tmp);
    return *this;
}

template<typename K, typename V>
util::multimap<K, V>::multimap(util::multimap<K, V>&& rhs) noexcept :
    m_kv(std::move(rhs.m_kv)),
    m_vk(std::move(rhs.m_vk))
{
    //
}

template<typename K, typename V>
util::multimap<K, V>& util::multimap<K, V>::operator=(util::multimap<K, V>&& rhs) noexcept
{
    m_kv = std::move(rhs.m_kv);
    m_vk = std::move(rhs.m_vk);
    
    return *this;
}

template<typename K, typename V>
V util::multimap<K, V>::at(const K& key) const
{
    auto it = m_kv.find(key);
    
    if (it == m_kv.end())
    {
        throw std::runtime_error("key does not exist.");
    }
    
    return it->second;
}

template<typename K, typename V>
K util::multimap<K, V>::at(const V& key) const
{
    auto it = m_vk.find(key);
    
    if (it == m_vk.end())
    {
        throw std::runtime_error("key does not exist.");
    }
    
    return it->second;
}

template<typename K, typename V>
const V& util::multimap<K, V>::ref_at(const K &key) const
{
    const auto it = m_kv.find(key);
    
    if (it == m_kv.end())
    {
        throw std::runtime_error("key does not exist.");
    }
    
    return it->second;
}

template<typename K, typename V>
const K& util::multimap<K, V>::ref_at(const V &key) const
{
    const auto it = m_vk.find(key);
    
    if (it == m_vk.end())
    {
        throw std::runtime_error("key does not exist.");
    }
    
    return it->second;
}

template<typename K, typename V>
void util::multimap<K, V>::insert(K key, V value)
{
    auto ita = m_kv.find(key);
    auto itb = m_vk.find(value);
    
    if (ita != m_kv.end())
    {
        m_vk.erase(ita->second);
    }
    
    if (itb != m_vk.end())
    {
        m_kv.erase(itb->second);
    }
    
    m_kv[key] = value;
    m_vk[value] = key;
}

template<typename K, typename V>
bool util::multimap<K, V>::contains(const K& key) const
{
    return m_kv.find(key) != m_kv.end();
}

template<typename K, typename V>
bool util::multimap<K, V>::contains(const V& key) const
{
    return m_vk.find(key) != m_vk.end();
}

template<typename K, typename V>
std::vector<K> util::multimap<K, V>::keys() const
{
    std::vector<K> res;
    
    for (const auto& it : m_kv)
    {
        res.push_back(it.first);
    }
    
    return res;
}

template<typename K, typename V>
std::vector<V> util::multimap<K, V>::values() const
{
    std::vector<V> res;
    
    for (const auto& it : m_kv)
    {
        res.push_back(it.second);
    }
    
    return res;
}

template<typename K, typename V>
size_t util::multimap<K, V>::erase(K key)
{
    auto it = m_kv.find(key);
    
    if (it == m_kv.end())
    {
        return 0;
    }
    
    m_vk.erase(it->second);
    
    m_kv.erase(key);
    
    return 1;
}

template<typename K, typename V>
size_t util::multimap<K, V>::erase(V key)
{
    auto it = m_vk.find(key);
    
    if (it == m_vk.end())
    {
        return 0;
    }
    
    m_kv.erase(it->second);
    
    m_vk.erase(key);
    
    return 1;
}

template<typename K, typename V>
size_t util::multimap<K, V>::size() const
{
    return m_kv.size();
}

template<typename K, typename V>
auto util::multimap<K, V>::find(const K& key) const
{
    return m_kv.find(key);
}

template<typename K, typename V>
auto util::multimap<K, V>::find(const V& key) const
{
    return m_vk.find(key);
}

template<typename K, typename V>
auto util::multimap<K, V>::endk() const
{
    return m_kv.end();
}

template<typename K, typename V>
auto util::multimap<K, V>::endv() const
{
    return m_vk.end();
}

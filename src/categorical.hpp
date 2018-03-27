//
//  categorical.hpp
//  categorical
//
//  Created by Nick Fagan on 3/20/18.
//

#pragma once

#include "types.hpp"
#include "multimap.hpp"
#include "bit_array.hpp"
#include <vector>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <functional>

namespace util {
    class categorical;
    
    struct combinations_t
    {
        std::vector<std::vector<util::u64>> indices;
        std::vector<std::string> combinations;
    };
    
    namespace categorical_status {
        static constexpr util::u32 OK = 0u;
        static constexpr util::u32 CATEGORY_EXISTS = 1u;
        static constexpr util::u32 CATEGORY_DOES_NOT_EXIST = 2u;
        static constexpr util::u32 LABEL_EXISTS_IN_OTHER_CATEGORY = 3u;
        static constexpr util::u32 LABEL_IS_INVALID_COLLAPSED_EXPRESSION = 4u;
        static constexpr util::u32 WRONG_CATEGORY_SIZE = 5u;
        static constexpr util::u32 CATEGORIES_DO_NOT_MATCH = 6u;
        static constexpr util::u32 CAT_OVERFLOW = 7u;
        static constexpr util::u32 COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY = 8u;
        static constexpr util::u32 OUT_OF_BOUNDS = 9u;
        static constexpr util::u32 WRONG_INDEX_SIZE = 10u;
    }
    
    util::u32 get_id(std::function<bool(util::u32)> exists_func);
}

class util::categorical
{
public:
    categorical();
    ~categorical();
    
    bool operator ==(const util::categorical& other) const;
    bool operator !=(const util::categorical& other) const;
    
    std::vector<util::u64> find(const std::vector<std::string>& labels,
                                util::u64 index_offset = 0) const;
    
    std::vector<std::vector<util::u64>> find_all(const std::vector<std::string>& categories,
                                    util::u64 index_offset = 0) const;
    util::combinations_t find_allc(const std::vector<std::string>& categories,
                                   util::u64 index_offset = 0) const;
    
    std::vector<std::vector<util::u64>> keep_each(const std::vector<std::string>& categories,
                                       util::u64 index_offset = 0);
    util::combinations_t keep_eachc(const std::vector<std::string>& categories,
                                   util::u64 index_offset = 0);
    
    void one();
    void prune();
    
    std::vector<std::string> get_categories() const;
    std::vector<std::string> get_labels() const;
    
    std::vector<std::string> full_category(const std::string& category, bool* exists) const;
    std::vector<std::string> full_category(const std::string& category) const;
    
    std::vector<std::string> partial_category(const std::string& category,
                                              const std::vector<util::u64>& at_indices,
                                              util::u32* status,
                                              util::s64 index_offset = 0) const;
    
    std::vector<std::string> in_category(const std::string& category, bool* exists) const;
    std::vector<std::string> in_category(const std::string& category) const;
    
    void collapse_category(const std::string& category, bool* exists);
    void collapse_category(const std::string& category);
    
    void remove_category(const std::string& category, bool* exists);
    
    util::u32 keep(std::vector<util::u64>& at_indices, util::s64 offset = 0);
    
    void reserve(util::u64 rows);
    void repeat(util::u64 times);
    
    util::u32 append(const categorical& other);
    util::u32 assign(const util::categorical& other,
                     const std::vector<util::u64>& to_indices,
                     util::s64 index_offset);
    util::u32 assign(const util::categorical& other,
                                        const std::vector<util::u64>& to_indices,
                                        const std::vector<util::u64>& from_indices,
                                        util::s64 index_offset);
    
    void empty();
    
    bool has_category(const std::string& category) const;
    bool has_label(const std::string& label) const;
    
    util::u64 n_categories() const;
    util::u64 n_labels() const;
    
    util::u32 set_category(const std::string& category, const std::vector<std::string>& full_category);
    util::u32 set_category(const std::string& category, const std::vector<std::string>& part_category,
                           const util::bit_array& at_indices);
    util::u32 fill_category(const std::string& category, const std::string& lab);
    util::u32 add_category(const std::string& category);
    util::u32 require_category(const std::string& category);
    
    util::u64 size() const;
    util::u64 count(const std::string& lab) const;
private:
    util::u64 m_size;
    util::u32 m_next_id;
    
    std::vector<std::vector<util::u32>> m_labels;
    std::unordered_map<std::string, util::u64> m_category_indices;
    util::multimap<std::string, util::u32> m_label_ids;
    std::unordered_map<std::string, std::string> m_in_category;
    std::unordered_set<std::string> m_collapsed_expressions;
    
private:
    bool has_label(util::u32 label_id) const;
    
    util::u32 get_next_label_id();
    
    void unchecked_add_category(const std::string& category, const std::string& collapsed_expression);
    void unchecked_in_category(std::vector<std::string>& out, const std::string& category) const;
    void unchecked_full_category(std::vector<std::string>& out, const std::string& category) const;
    void unchecked_keep_each(const std::vector<std::vector<util::u64>>& indices, util::u64 index_offset);
    
    bool categories_match(const categorical& other) const;
    
    void set_collapsed_expressions(std::vector<util::u32>& labs,
                                   const std::string& category,
                                   const std::string& collapsed_expression,
                                   util::u64 start_offset = 0);
    
    void set_all_collapsed_expressions(util::u64 start_offset = 0);
    
    std::string get_collapsed_expression(const std::string& for_cat) const;
    
    void resize(util::u64 rows);
    
    static util::u32 get_id(const categorical* self, const categorical* other,
                const std::unordered_set<util::u32>& new_ids);
    
    static void replace_labels(std::vector<std::vector<util::u32>>& labels,
                               util::u64 start, util::u64 stop,
                               const std::unordered_map<util::u32, util::u32>& replace_map);
    
    static util::bit_array assign_bit_array(const std::vector<util::u32>& labels, util::u32 lab);
    
    static util::u32 bounds_check(const std::vector<util::u64>& indices,
                                  util::u64 n_check,
                                  util::u64 end,
                                  util::u64 index_offset);
};

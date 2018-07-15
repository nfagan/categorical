//
//  categorical.hpp
//  categorical
//
//  Created by Nick Fagan on 3/20/18.
//

#pragma once

#include "config.hpp"
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
    
    struct labels_t
    {
        std::vector<util::u32> ids;
        std::vector<std::string> labels;
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
        static constexpr util::u32 INCOMPATIBLE_SIZES = 11u;
    }
    
    util::u32 get_id(std::function<bool(util::u32)> exists_func);
    
    //  matlab conversion
    void from_matlab_categorical(util::categorical* self,
                                 const std::vector<std::string>& categories,
                                 const std::vector<std::string>& labels,
                                 util::u32* lab_ids,
                                 util::u64 rows,
                                 util::u64 cols);
}

class util::categorical
{
public:
    categorical() = default;
    ~categorical() = default;
    
    bool operator ==(const util::categorical& other) const;
    bool operator !=(const util::categorical& other) const;
    
    std::vector<util::u64> find(const std::vector<std::string>& labels,
                                util::u64 index_offset = 0) const;
    
    std::vector<util::u64> find(const std::vector<std::string>& labels,
                                const std::vector<util::u64>& indices,
                                util::u32* status,
                                util::u64 index_offset = 0) const;
    
    std::vector<util::u64> find_not(const std::vector<std::string>& labels,
                                    util::u64 index_offset = 0) const;
    
    std::vector<util::u64> find_not(const std::vector<std::string>& labels,
                                    const std::vector<util::u64>& indices,
                                    util::u32* status,
                                    util::u64 index_offset = 0) const;
    
    std::vector<util::u64> find_or(const std::vector<std::string>& labels,
                                   util::u64 index_offset = 0) const;
    
    std::vector<util::u64> find_or(const std::vector<std::string>& labels,
                                   const std::vector<util::u64>& indices,
                                   util::u32* status,
                                   util::u64 index_offset = 0) const;
    
    std::vector<util::u64> find_none(const std::vector<std::string>& labels,
                                     util::u64 index_offset = 0) const;
    
    std::vector<util::u64> find_none(const std::vector<std::string>& labels,
                                     const std::vector<util::u64>& indices,
                                     util::u32* status,
                                     util::u64 index_offset = 0) const;
    
    std::vector<std::vector<util::u64>> find_all(const std::vector<std::string>& categories,
                                    util::u64 index_offset = 0) const;
    
    std::vector<std::vector<util::u64>> find_all(const std::vector<std::string>& categories,
                                                 const std::vector<util::u64>& indices,
                                                 util::u64 index_offset = 0) const;
    
    std::vector<std::vector<util::u64>> find_all(const std::vector<std::string>& categories,
                                                 const std::vector<util::u64>& indices,
                                                 util::u32* status,
                                                 util::u64 index_offset = 0) const;
    
    util::combinations_t find_allc(const std::vector<std::string>& categories,
                                   util::u64 index_offset = 0) const;
    
    util::combinations_t find_allc(const std::vector<std::string>& categories,
                                   const std::vector<util::u64>& indices,
                                   util::u32* status,
                                   util::u64 index_offset = 0) const;
    
    std::vector<std::vector<util::u64>> keep_each(const std::vector<std::string>& categories,
                                       util::u64 index_offset = 0);
    
    std::vector<std::vector<util::u64>> keep_each(const std::vector<std::string>& categories,
                                                  const std::vector<util::u64>& indices,
                                                  util::u32* status,
                                                  util::u64 index_offset = 0);
    
    util::combinations_t keep_eachc(const std::vector<std::string>& categories,
                                   util::u64 index_offset = 0);
    
    util::combinations_t keep_eachc(const std::vector<std::string>& categories,
                                    const std::vector<util::u64>& indices,
                                    util::u32* status,
                                    util::u64 index_offset = 0);
    
    void one();
    void empty();
    util::u64 prune();
    
    std::vector<std::string> get_uniform_categories() const;
    std::vector<std::string> get_categories() const;
    std::vector<std::string> get_labels() const;
    util::labels_t get_labels_and_ids() const;
    std::vector<const std::vector<util::u32>*> get_label_mat() const;
    std::vector<const std::vector<util::u32>*> get_label_mat(const std::vector<std::string>& categories,
                                                             bool* exists) const;
    
    std::vector<std::string> full_category(const std::string& category, bool* exists) const;
    std::vector<std::string> full_category(const std::string& category) const;
    
    std::vector<std::string> partial_category(const std::string& category,
                                              const std::vector<util::u64>& at_indices,
                                              util::u32* status,
                                              util::u64 index_offset = 0) const;
    
    bool is_uniform_category(const std::string& cat, bool* exists) const;
    
    std::vector<std::string> in_category(const std::string& category, bool* exists) const;
    std::vector<std::string> in_category(const std::string& category) const;
    std::vector<std::string> in_categories(const std::vector<std::string>& categories, bool* exist) const;
    
    void collapse_category(const std::string& category, bool* exists);
    void collapse_category(const std::string& category);
    
    void remove_category(const std::string& category, bool* exists);
    
    util::u32 keep(const std::vector<util::u64>& at_indices, util::u64 offset = 0);
    std::vector<util::u64> remove(const std::vector<std::string>& labels);
    
    void reserve(util::u64 rows);
    void repeat(util::u64 times);
    
    util::u32 append(const util::categorical& other);
    util::u32 append(const util::categorical &other,
                     const std::vector<util::u64>& indices,
                     util::u64 index_offset = 0);
    
    util::u32 append_one(const util::categorical& other);
    util::u32 append_one(const util::categorical& other,
                         const std::vector<util::u64>& indices,
                         util::u64 index_offset = 0);
    
    util::u32 assign(const util::categorical& other,
                     const std::vector<util::u64>& to_indices,
                     util::u64 index_offset = 0);
    util::u32 assign(const util::categorical& other,
                     const std::vector<util::u64>& to_indices,
                     const std::vector<util::u64>& from_indices,
                     util::u64 index_offset = 0);
    
    util::u32 merge(const util::categorical& other);
    util::u32 merge_new(const util::categorical& other);
    
    bool has_category(const std::string& category) const;
    bool has_label(const std::string& label) const;
    
    util::u64 n_categories() const;
    util::u64 n_labels() const;
    
    util::u32 set_category(const std::string& category, const std::vector<std::string>& full_category);
    util::u32 set_category(const std::string& category, const std::vector<std::string>& part_category,
                           const std::vector<util::u64>& at_indices,
                           util::u64 index_offset = 0);
    
    util::u32 fill_category(const std::string& category, const std::string& lab);
    
    util::u32 add_category(const std::string& category);
    util::u32 require_category(const std::string& category);
    util::u32 rename_category(const std::string& from, const std::string& to);
    
    util::u32 replace_labels(const std::string& from, const std::string& with);
    util::u32 replace_labels(const std::vector<std::string>& from, const std::string& with, bool test_scalar = true);
    
    util::u64 size() const;
    util::u64 count(const std::string& lab) const;
    util::u64 count(const std::string& lab,
                    const std::vector<util::u64>& indices,
                    util::u32* status,
                    util::u64 index_offset = 0) const;
    
    static util::categorical empty_copy(const util::categorical& to_copy);
    
    bool progenitors_match(const util::categorical& other) const;
    
    friend void from_matlab_categorical(util::categorical* self,
                                        const std::vector<std::string>& categories,
                                        const std::vector<std::string>& labels,
                                        util::u32* lab_ids,
                                        util::u64 rows,
                                        util::u64 cols);
private:
    std::vector<std::vector<util::u32>> m_labels;
    std::unordered_map<std::string, util::u64> m_category_indices;
    util::multimap<std::string, util::u32> m_label_ids;
    std::unordered_map<std::string, std::string> m_in_category;
    std::unordered_set<std::string> m_collapsed_expressions;
    
private:
    bool has_label(util::u32 label_id) const;
    
    util::u32 get_next_label_id();
    util::u32 get_label_id_or_0(const std::string& lab, bool* exist) const;
    
    void unchecked_add_category(const std::string& category, const std::string& collapsed_expression);
    void unchecked_in_category(std::vector<std::string>& out, const std::string& category) const;
    void unchecked_full_category(std::vector<std::string>& out, const std::string& category) const;
    void unchecked_keep_each(const std::vector<std::vector<util::u64>>& indices, util::u64 index_offset);
    void unchecked_insert_label(const std::string& lab, const util::u32 id, const std::string& category);
    const std::vector<util::u32>& unchecked_get_label_column(const std::string& lab) const;
    
    bool unchecked_eq_progenitors_match(const util::categorical& other, util::u64 sz) const;
    
    void unchecked_append_progenitors_match(const util::categorical& other,
                                            util::u64 own_sz,
                                            util::u64 other_sz);
    util::u32 unchecked_append_progenitors_match_indexed(const util::categorical& other,
                                                         util::u64 own_sz,
                                                         util::u64 other_sz,
                                                         const std::vector<util::u64>& indices,
                                                         util::u64 index_offset);
    void unchecked_assign_progenitors_match(const util::categorical& other,
                                            const std::vector<util::u64>& to_indices,
                                            util::u64 index_offset);
    void unchecked_assign_progenitors_match(const util::categorical& other,
                                            const std::vector<util::u64>& to_indices,
                                            const std::vector<util::u64>& from_indices,
                                            util::u64 index_offset,
                                            bool is_scalar);
    
    util::u32 append_impl(const util::categorical& other,
                          const bool use_indices,
                          const std::vector<util::u64>& indices,
                          util::u64 index_offset);
    
    util::u32 append_one_impl(const util::categorical& other,
                              const bool use_indices,
                              const std::vector<util::u64>& indices,
                              util::u64 index_offset);
    
    bool categories_match(const categorical& other) const;
    bool is_uniform(const std::vector<util::u32>& lab_ids) const;
    bool is_uniform(const std::vector<util::u32>& lab_ids,
                    const std::vector<util::u64>& indices,
                    util::u32* status,
                    util::u64 index_offset) const;
    
    std::vector<util::u64> find_impl(const std::vector<std::string>& labels,
                                     const bool use_indices,
                                     const bool flip_index,
                                     const std::vector<util::u64>& indices,
                                     util::u32* status,
                                     util::u64 index_offset) const;
    
    std::vector<util::u64> find_or_impl(const std::vector<std::string>& labels,
                                        const bool use_indices,
                                        const bool flip_index,
                                        const std::vector<util::u64>& indices,
                                        util::u32* status,
                                        util::u64 index_offset) const;
    
    util::combinations_t find_allc_impl(const std::vector<std::string>& categories,
                                        const bool use_indices,
                                        const std::vector<util::u64>& indices,
                                        util::u32* status,
                                        util::u64 index_offset) const;
    
    std::vector<util::u64> get_category_indices(const std::vector<std::string>& cats,
                                                const util::u64 n_cats, bool* exist) const;
    
    void set_collapsed_expressions(std::vector<util::u32>& labs,
                                   const std::string& category,
                                   const std::string& collapsed_expression,
                                   util::u64 start_offset = 0);
    
    void set_all_collapsed_expressions(util::u64 start_offset = 0);
    
    std::string get_collapsed_expression(const std::string& for_cat) const;
    
    void resize(util::u64 rows);
    
    util::u32 reconcile_new_label_ids(const util::categorical& other,
                                      util::multimap<std::string, util::u32>& tmp_label_ids,
                                      std::unordered_map<std::string, std::string>& tmp_in_cat,
                                      std::unordered_map<util::u32, util::u32>& replace_other,
                                      const bool overwrite_existing_categories = true) const;
    
    void append_fill_new_label_ids(const util::categorical& other,
                                   const std::unordered_map<util::u32, util::u32>& replace_other_labs,
                                   util::u64 own_sz,
                                   util::u64 other_sz);
    util::u32 append_fill_new_label_ids_indexed(const util::categorical& other,
                                                const std::unordered_map<util::u32, util::u32>& replace_other_labs,
                                                util::u64 own_sz,
                                                util::u64 other_sz,
                                                const std::vector<util::u64>& indices,
                                                util::u64 index_offset);
    
    util::u32 merge(const util::categorical& other, const bool overwrite_existing_cats);
    
    void merge_fill_new_label_ids(const util::categorical& other,
                                  const std::vector<std::string>& categories,
                                  std::unordered_map<util::u32, util::u32>& replace_other_labs,
                                  bool is_scalar,
                                  bool sizes_match,
                                  util::u64 own_sz);
    
    util::u32 merge_require_categories(const util::categorical& other, std::vector<std::string>& new_categories);
    util::u32 merge_check_collapsed_expressions(const util::categorical& other,
                                                const bool overwrite_existing_categories = true) const;
    
    static util::u32 find_flipped_apply_mask(util::bit_array& final_index,
                                             const util::u64 sz,
                                             const std::vector<util::u64>& indices,
                                             const util::u64 index_offset);
    
    static std::vector<util::u64> find_flipped_get_complete_index(const bool use_indices,
                                                                  const util::u64 sz,
                                                                  const std::vector<util::u64>& indices,
                                                                  const util::u64 index_offset,
                                                                  util::u32* status);
    
    static util::u32 get_id(const categorical* self, const categorical* other,
                            const std::unordered_set<util::u32>& new_ids);
    
    static void replace_labels(std::vector<std::vector<util::u32>>& labels,
                               util::u64 start, util::u64 stop,
                               const std::unordered_map<util::u32, util::u32>& replace_map);
    
    static util::u32 assign_bit_array(util::bit_array& mask,
                                      const std::vector<util::u64>& at_indices,
                                      util::u64 index_offset);
    
    static util::bit_array assign_bit_array(const std::vector<util::u32>& labels, util::u32 lab);
    static util::bit_array assign_bit_array(const std::vector<util::u32>& labels,
                                            util::u32 lab,
                                            const std::vector<util::u64>& indices,
                                            util::u32* status,
                                            util::u64 index_offsex);
    
    static util::u32 bounds_check(const util::u64* data,
                                  util::u64 n_check,
                                  util::u64 end,
                                  util::u64 index_offset);
    
    static util::u64 maximum(const std::vector<util::u64>& indices, util::u64 end);

private:
    struct progenitor_ids
    {
        progenitor_ids();
        ~progenitor_ids() = default;
        
        void randomize();
        bool exists(util::u32 id) const;
        
        bool operator ==(const util::categorical::progenitor_ids& other) const;
        bool operator !=(const util::categorical::progenitor_ids& other) const;
        
        util::u32 a;
        util::u32 b;
    } m_progenitor_ids;
};

//
//  set_membership.cpp
//  categorical
//
//  Created by Nick Fagan on 10/18/19.
//

#include "set_membership.hpp"
#include "categorical.hpp"
#include "helpers.hpp"

namespace
{
    std::vector<util::u64> make_range(const util::u64 num)
    {
        std::vector<util::u64> result;
        for (util::u64 i = 0; i < num; i++)
        {
            result.push_back(i);
        }
        
        return result;
    }
    
    std::vector<std::string> intersecting_sorted_categories(const std::vector<std::string>& cats_a,
                                                            const std::vector<std::string>& cats_b)
    {
        std::vector<std::string> categories;
        std::set_intersection(cats_a.begin(), cats_a.end(),
                              cats_b.begin(), cats_b.end(), std::back_inserter(categories));
        
        return categories;
    }
    
    std::vector<std::string> unique_categories(std::vector<std::string> cats)
    {
        std::vector<std::string> result;
        std::sort(cats.begin(), cats.end());
        std::unique_copy(cats.begin(), cats.end(), std::back_inserter(result));
        return result;
    }
    
    std::vector<std::string> set_difference_sorted_categories(const std::vector<std::string>& cats_a,
                                                              const std::vector<std::string>& cats_b)
    {
        std::vector<std::string> categories;
        std::set_difference(cats_a.begin(), cats_a.end(),
                            cats_b.begin(), cats_b.end(), std::back_inserter(categories));
        
        return categories;
    }
    
    std::vector<std::vector<util::u32>> unique_rows(std::unordered_map<std::string, util::VisitedRow>& visited_complete_rows,
                                                    const std::vector<std::vector<util::u32>>& ids,
                                                    const std::vector<util::u64>& indices,
                                                    const bool use_indices,
                                                    const util::u64 index_offset,
                                                    util::u32* status)
    {
        using util::u32;
        using util::u64;
        
        const u64 num_cols = ids.size();
        const u64 max_rows = util::num_rows_in_matrix(ids);
        const u64 num_rows = use_indices ? indices.size() : max_rows;
        
        std::vector<std::vector<u32>> result(num_cols);
        std::string row_hash = util::make_label_id_hash_string(num_cols);
        
        for (u64 i = 0; i < num_rows; i++)
        {
            const u64 row = use_indices ? (indices[i] - index_offset) : i;
            if (row >= max_rows)
            {
                *status = util::categorical_status::OUT_OF_BOUNDS;
                return {};
            }
            
            util::build_row_hash(&row_hash[0], ids, row, num_cols);
            
            const auto visited_it = visited_complete_rows.find(row_hash);
            if (visited_it == visited_complete_rows.end())
            {
                visited_complete_rows.emplace(row_hash, util::VisitedRow(i, row));
                
                for (u64 j = 0; j < num_cols; j++)
                {
                    result[j].push_back(ids[j][row]);
                }
            }
        }
        
        *status = util::categorical_status::OK;
        return result;
    }
    
    std::vector<std::vector<util::u32>> unique_rows_to_combine(std::unordered_set<std::string>& visited_complete_rows,
                                                               std::unordered_map<std::string, util::VisitedRow>& visited_shared_rows,
                                                               const std::vector<std::vector<util::u32>>& ids,
                                                               const std::vector<util::u64>& category_indices,
                                                               const std::vector<util::u64>& shared_category_indices,
                                                               const std::vector<util::u64>& unique_category_indices,
                                                               const std::vector<util::u64>& indices,
                                                               const bool use_indices,
                                                               const util::u64 index_offset,
                                                               util::u32* status)
    {
        using util::u32;
        using util::u64;
        using util::s64;
        
        *status = util::categorical_status::OK;
        
        std::vector<std::vector<util::u32>> result;
        
        const u64 num_categories = category_indices.size();
        const u64 num_shared = shared_category_indices.size();
        const u64 num_unique = unique_category_indices.size();
        const u64 max_rows = ids.empty() ? 0 : ids[0].size();
        const u64 num_rows = use_indices ? indices.size() : max_rows;
        
        std::string complete_row_hash;
        std::string shared_row_hash;
        
        char* complete_row_hash_ptr = nullptr;
        char* shared_row_hash_ptr = nullptr;
        
        if (num_categories > 0)
        {
            complete_row_hash = util::make_label_id_hash_string(num_categories);
            complete_row_hash_ptr = &complete_row_hash[0];
            result.resize(num_categories);
        }
        
        if (num_shared > 0)
        {
            shared_row_hash = util::make_label_id_hash_string(num_shared);
            shared_row_hash_ptr = &shared_row_hash[0];
        }
        
        u64 unique_row_index = 0;
        
        for (u64 i = 0; i < num_rows; i++)
        {
            u64 row_index = i;
            
            if (use_indices)
            {
                row_index = indices[i] - index_offset;
                if (row_index >= max_rows)
                {
                    *status = util::categorical_status::OUT_OF_BOUNDS;
                    return std::vector<std::vector<u32>>();
                }
            }
            
            util::build_row_hash(complete_row_hash_ptr, ids, row_index, category_indices);
            util::build_row_hash(shared_row_hash_ptr, ids, row_index, shared_category_indices);
            
            //  Add it to the set.
            if (visited_complete_rows.count(complete_row_hash) == 0)
            {
                visited_complete_rows.emplace(complete_row_hash);
                
                for (u64 j = 0; j < num_categories; j++)
                {
                    result[j].push_back(ids[category_indices[j]][row_index]);
                }
                
                //  This is a new row.
                unique_row_index++;
            }
        
            auto visited_shared_it = visited_shared_rows.find(shared_row_hash);
            if (visited_shared_it == visited_shared_rows.end())
            {
                //  Unique row index is one ahead.
                visited_shared_rows.emplace(shared_row_hash, util::VisitedRow(unique_row_index-1, row_index));
                
                if (num_unique > 0)
                {
                    util::VisitedRow& row = visited_shared_rows.at(shared_row_hash);
                    std::vector<s64>& remaining_category_ids = row.remaining_ids;
                    
                    for (u64 j = 0; j < num_unique; j++)
                    {
                        const u32 remaining_id = ids[unique_category_indices[j]][row_index];
                        remaining_category_ids.push_back(remaining_id);
                    }
                }
            }
            else
            {
                util::VisitedRow& row = visited_shared_it->second;
                
                for (u64 j = 0; j < num_unique; j++)
                {
                    const s64 curr_id = row.remaining_ids[j];
                    const u32 test_id = ids[unique_category_indices[j]][row_index];
                    
                    if (curr_id == -1 || curr_id != test_id)
                    {
                        row.remaining_ids[j] = -1;
                    }
                }
            }
        }
        
        return result;
    }
}

util::set_unique::set_unique(const util::categorical& a) : a(a)
{
    //
}

util::categorical util::set_unique::operator()() const
{
    u32 ignore_status;
    return unique_impl({}, false, 0, &ignore_status);
}

util::categorical util::set_unique::operator()(const std::vector<util::u64>& indices,
                                               util::u32* status,
                                               const util::u64 index_offset) const
{
    return unique_impl(indices, true, index_offset, status);
}

util::categorical util::set_unique::unique_impl(const std::vector<util::u64>& indices,
                                                const bool use_indices,
                                                const util::u64 index_offset,
                                                util::u32* status) const
{
    util::categorical result = categorical::empty_copy(a);
    std::unordered_map<std::string, VisitedRow> visited_rows;
    
    result.m_labels = unique_rows(visited_rows, a.m_labels, indices, use_indices, index_offset, status);
    
    return result;
}

util::set_union::set_union(const util::categorical& a, const util::categorical& b) : a(a), b(b)
{
    //
}

void util::set_union::append_unique_rows_progenitors_match(std::vector<std::vector<util::u32>>& ids_a,
                                                           std::unordered_map<std::string, util::VisitedRow>& visited_rows_a,
                                                           const std::vector<std::vector<util::u32>>& ids_b,
                                                           const std::vector<util::u64>& indices,
                                                           const bool use_indices,
                                                           const util::u64 index_offset,
                                                           util::u32* status)
{
    const u64 orig_num_rows_a = num_rows_in_matrix(ids_a);
    const u64 max_rows = num_rows_in_matrix(ids_b);
    const u64 num_rows = use_indices ? indices.size() : max_rows;
    const u64 num_cols = ids_b.size();
    std::string row_hash = make_label_id_hash_string(num_cols);
    
    for (u64 i = 0; i < num_rows; i++)
    {
        const u64 row = use_indices ? (indices[i] - index_offset) : i;
        if (row >= max_rows)
        {
            *status = util::categorical_status::OUT_OF_BOUNDS;
            return;
        }
        
        build_row_hash(&row_hash[0], ids_b, row, num_cols);
        
        if (visited_rows_a.count(row_hash) == 0)
        {
            const u64 index_in_unique = i + orig_num_rows_a;
            visited_rows_a.emplace(row_hash, util::VisitedRow(index_in_unique, row));
            for (u64 j = 0; j < num_cols; j++)
            {
                ids_a[j].push_back(ids_b[j][row]);
            }
        }
    }
}

void util::set_union::append_unique_rows(util::categorical& a,
                                         const util::categorical& b,
                                         std::vector<std::vector<util::u32>>& ids_a,
                                         std::unordered_map<std::string, util::VisitedRow>& visited_rows_a,
                                         const std::vector<std::vector<util::u32>>& ids_b,
                                         const std::vector<std::string>& categories,
                                         const std::vector<util::u64>& category_indices_a,
                                         const std::vector<util::u64>& category_indices_b,
                                         const std::vector<util::u64>& indices,
                                         const bool use_indices,
                                         const util::u64 index_offset,
                                         util::u32* status)
{
    const u64 orig_num_rows_a = num_rows_in_matrix(ids_a);
    const u64 num_cols = ids_b.size();
    const u64 max_rows = num_rows_in_matrix(ids_b);
    const u64 num_rows = use_indices ? indices.size() : max_rows;
    
    std::unordered_map<u32, u32> visited_ids_b;
    std::string row_hash_a = util::make_label_id_hash_string(num_cols);
    
    for (u64 i = 0; i < num_rows; i++)
    {
        const u64 row = use_indices ? (indices[i] - index_offset) : i;
        if (row >= max_rows)
        {
            *status = util::categorical_status::OUT_OF_BOUNDS;
            return;
        }
        
        for (u64 j = 0; j < num_cols; j++)
        {
            const u32 id_b = ids_b[category_indices_b[j]][row];
            const auto visited_it_b = visited_ids_b.find(id_b);
            u32 id_a;
            
            if (visited_it_b == visited_ids_b.end())
            {
                const std::string& label_b = b.m_label_ids.ref_at(id_b);
                const auto it_a = a.m_label_ids.find(label_b);
                if (it_a == a.m_label_ids.endk())
                {
                    const u32 label_status = a.add_label_unchecked_has_category(categories[j], label_b, &id_a);
                    if (label_status != categorical_status::OK)
                    {
                        *status = label_status;
                        return;
                    }
                }
                else
                {
                    id_a = it_a->second;
                }
                
                visited_ids_b.emplace(id_b, id_a);
            }
            else
            {
                id_a = visited_it_b->second;
            }
            
            std::memcpy(&row_hash_a[0] + category_indices_a[j]*sizeof(u32), &id_a, sizeof(u32));
        }
        
        if (visited_rows_a.count(row_hash_a) == 0)
        {
            const u64 index_in_unique = i + orig_num_rows_a;
            visited_rows_a.emplace(row_hash_a, VisitedRow(index_in_unique, row));
            
            for (u64 j = 0; j < num_cols; j++)
            {
                u32 id_a;
                std::memcpy(&id_a, &row_hash_a[0] + category_indices_a[j]*sizeof(u32), sizeof(u32));
                ids_a[category_indices_a[j]].push_back(id_a);
            }
        }
    }
}

bool util::set_union::build_union_row_hash(const util::categorical& a,
                                           const util::categorical& b,
                                           const std::vector<std::vector<u32>>& a_label_matrix,
                                           char* row_hash_ptr,
                                           const util::u64 row,
                                           const std::vector<util::u64>& category_indices)
{
    bool any_missing = false;
    
    if (a.progenitors_match(b))
    {
        build_row_hash(row_hash_ptr, a_label_matrix, row, category_indices);
    }
    else
    {
        const u64 num_cats_shared = category_indices.size();
        for (u64 j = 0; j < num_cats_shared; j++)
        {
            const std::string& label = a.m_label_ids.ref_at(a_label_matrix[category_indices[j]][row]);
            const auto& it_b = b.m_label_ids.find(label);
            
            //  Okay - use the b's label id to search.
            if (it_b != b.m_label_ids.endk())
            {
                const u32 id_b = it_b->second;
                std::memcpy(row_hash_ptr + j * sizeof(u32), &id_b, sizeof(u32));
            }
            //  b doesn't have this label, so it definitely doesn't have this row.
            else
            {
                any_missing = true;
                break;
            }
        }
    }
    
    return any_missing;
}

std::vector<std::string> util::set_union::get_uniform_category_labels(const util::categorical& a,
                                                                      const std::vector<std::string>& categories,
                                                                      const std::vector<util::u64>& indices,
                                                                      const bool use_indices,
                                                                      const util::u64 index_offset,
                                                                      util::u32* status)
{
    std::vector<std::string> result;
    const u64 sz = use_indices ? indices.size() : a.size();
    const u64 row0 = !use_indices ? 0 : indices.size() > 0 ? (indices[0] - index_offset) : 0;
    
    for (const auto& cat : categories)
    {
        bool is_uniform = false;
        
        if (use_indices)
        {
            is_uniform = a.is_uniform_category(cat, indices, status, index_offset);
            if (*status != categorical_status::OK)
            {
                return result;
            }
        }
        else
        {
            bool exists;
            is_uniform = a.is_uniform_category(cat, &exists);
            
            if (!exists)
            {
                *status = categorical_status::CATEGORY_DOES_NOT_EXIST;
                return result;
            }
        }
        
        if (sz > 0 && is_uniform)
        {
            const std::string& label = a.m_label_ids.ref_at(a.m_labels[a.m_category_indices.at(cat)][row0]);
            result.push_back(label);
        }
        else
        {
            result.push_back(a.get_collapsed_expression(cat));
        }
    }
    
    *status = categorical_status::OK;
    return result;
}

util::categorical util::set_union::make_combined(util::u32* status) const
{
    return set_combination_impl(status, {}, {}, 0, false);
}

util::categorical util::set_union::make_combined(const std::vector<util::u64>& mask_a,
                                                 const std::vector<util::u64>& mask_b,
                                                 util::u32* status,
                                                 const util::u64 index_offset) const
{
    return set_combination_impl(status, mask_a, mask_b, index_offset, true);
}

util::categorical util::set_union::make_union(util::u32* status) const
{
    if (!a.categories_match(b))
    {
        *status = categorical_status::CATEGORIES_DO_NOT_MATCH;
        return util::categorical();
    }
    
    return set_union_impl(status, a.get_categories(), {}, {}, 0, false);
}

util::categorical util::set_union::make_union(const std::vector<util::u64>& mask_a,
                                              const std::vector<util::u64>& mask_b,
                                              util::u32* status,
                                              const util::u64 index_offset) const
{
    if (!a.categories_match(b))
    {
        *status = categorical_status::CATEGORIES_DO_NOT_MATCH;
        return util::categorical();
    }
    
    return set_union_impl(status, a.get_categories(), mask_a, mask_b, index_offset, true);
}

util::categorical util::set_union::make_union(const std::vector<std::string>& categories, util::u32* status) const
{
    return set_union_impl(status, categories, {}, {}, 0, false);
}

util::categorical util::set_union::make_union(const std::vector<std::string>& categories,
                                              const std::vector<util::u64>& mask_a,
                                              const std::vector<util::u64>& mask_b,
                                              util::u32* status,
                                              const util::u64 index_offset) const
{
    return set_union_impl(status, categories, mask_a, mask_b, index_offset, true);
}

#define CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(identifier) \
    if ((identifier) != util::categorical_status::OK) \
    { \
        *status = (identifier); \
        return util::categorical(); \
    }

#define CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL() \
    if (*status != categorical_status::OK) \
    { \
        return util::categorical(); \
    }

util::categorical util::set_union::set_union_impl_matching_categories(util::u32* status,
                                                                      const std::vector<std::string>& categories,
                                                                      const std::vector<util::u64>& mask_a,
                                                                      const std::vector<util::u64>& mask_b,
                                                                      const util::u64 index_offset,
                                                                      const bool use_indices) const
{
    const std::vector<u64> cat_inds_a = a.get_category_indices_unchecked_has_category(categories);
    const std::vector<u64> cat_inds_b = b.get_category_indices_unchecked_has_category(categories);
    
    util::categorical result = categorical::empty_copy(a);
    
    std::unordered_map<std::string, VisitedRow> visited_rows_a;
    result.m_labels = unique_rows(visited_rows_a, a.m_labels, mask_a, use_indices, index_offset, status);
    
    if (result.progenitors_match(b))
    {
        append_unique_rows_progenitors_match(result.m_labels, visited_rows_a, b.m_labels, mask_b, use_indices, index_offset, status);
    }
    else
    {
        append_unique_rows(result, b, result.m_labels, visited_rows_a, b.m_labels, categories,
                           cat_inds_a, cat_inds_b, mask_b, use_indices, index_offset, status);
    }
    
    CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
    
    return result;
}

util::categorical util::set_union::set_union_impl(util::u32 *status,
                                                  const std::vector<std::string>& in_categories,
                                                  const std::vector<util::u64>& mask_a,
                                                  const std::vector<util::u64>& mask_b,
                                                  const util::u64 index_offset,
                                                  const bool use_indices) const
{
    *status = categorical_status::OK;
    
    if (!a.has_categories(in_categories) || !b.has_categories(in_categories))
    {
        *status = categorical_status::CATEGORY_DOES_NOT_EXIST;
        return util::categorical();
    }
    
    const std::vector<std::string> categories = unique_categories(in_categories);
    const std::vector<std::string> cats_shared = intersecting_sorted_categories(a.get_categories(), b.get_categories());
    //  Remaining categories to fill in.
    const std::vector<std::string> cats_remaining = set_difference_sorted_categories(cats_shared, categories);
    
    //  Fast path when categories are the same between a and b, and all categories are specified in categories.
    if (cats_shared.size() == a.n_categories() && cats_shared.size() == b.n_categories())
    {
        return set_union_impl_matching_categories(status, categories, mask_a, mask_b, index_offset, use_indices);
    }
    
    const std::vector<u64> cat_inds_a = a.get_category_indices_unchecked_has_category(categories);
    const std::vector<u64> cat_inds_b = b.get_category_indices_unchecked_has_category(categories);
    
    const std::vector<u64> cat_inds_remaining_a = a.get_category_indices_unchecked_has_category(cats_remaining);
    const std::vector<u64> cat_inds_remaining_b = b.get_category_indices_unchecked_has_category(cats_remaining);
    const std::vector<u64> cat_inds_shared_a = a.get_category_indices_unchecked_has_category(cats_shared);
    const std::vector<u64> cat_inds_shared_b = b.get_category_indices_unchecked_has_category(cats_shared);
    
    std::vector<std::vector<u32>> unique_ids_a;
    std::vector<std::vector<u32>> unique_ids_b;
    
    std::unordered_map<std::string, VisitedRow> visited_shared_rows_a;
    std::unordered_map<std::string, VisitedRow> visited_shared_rows_b;
    
    std::unordered_set<std::string> visited_rows_a;
    std::unordered_set<std::string> visited_rows_b;
    
    if (use_indices)
    {
        unique_ids_a = unique_rows_to_combine(visited_rows_a, visited_shared_rows_a, a.m_labels,
                                              cat_inds_a, cat_inds_a, cat_inds_remaining_a, mask_a, true, index_offset, status);
        CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
        
        unique_ids_b = unique_rows_to_combine(visited_rows_b, visited_shared_rows_b, b.m_labels,
                                              cat_inds_b, cat_inds_b, cat_inds_remaining_b, mask_b, true, index_offset, status);
        CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
    }
    else
    {
        unique_ids_a = unique_rows_to_combine(visited_rows_a, visited_shared_rows_a, a.m_labels,
                                              cat_inds_a, cat_inds_a, cat_inds_remaining_a, {}, false, 0, status);
        unique_ids_b = unique_rows_to_combine(visited_rows_b, visited_shared_rows_b, b.m_labels,
                                              cat_inds_b, cat_inds_b, cat_inds_remaining_b, {}, false, 0, status);
    }
    
    return util::categorical();
}

util::categorical util::set_union::set_combination_impl(util::u32* status,
                                                        const std::vector<util::u64>& mask_a,
                                                        const std::vector<util::u64>& mask_b,
                                                        const util::u64 index_offset,
                                                        const bool use_indices) const
{
    *status = categorical_status::OK;
    
    const std::vector<std::string> cats_shared = intersecting_sorted_categories(a.get_categories(), b.get_categories());
    const std::vector<std::string> cats_a_only = a.get_categories_except(cats_shared);
    const std::vector<std::string> cats_b_only = b.get_categories_except(cats_shared);
    
    const u64 num_cats_shared = cats_shared.size();
    const u64 num_cats_b_only = cats_b_only.size();
    const u64 num_cats_a_only = cats_a_only.size();
    const u64 num_cats_total = num_cats_shared + num_cats_a_only + num_cats_b_only;
    
    const std::vector<u64> cat_inds_shared_a = a.get_category_indices_unchecked_has_category(cats_shared);
    const std::vector<u64> cat_inds_shared_b = b.get_category_indices_unchecked_has_category(cats_shared);
    const std::vector<u64> cat_inds_a_only = a.get_category_indices_unchecked_has_category(cats_a_only);
    const std::vector<u64> cat_inds_b_only = b.get_category_indices_unchecked_has_category(cats_b_only);
    
    const std::vector<u64> cat_inds_range_a = make_range(a.n_categories());
    const std::vector<u64> cat_inds_range_b = make_range(b.n_categories());
    
    std::vector<std::vector<util::u32>> unique_ids_a;
    std::vector<std::vector<util::u32>> unique_ids_b;
    
    std::unordered_map<std::string, VisitedRow> visited_shared_rows_a;
    std::unordered_map<std::string, VisitedRow> visited_shared_rows_b;
    
    std::unordered_set<std::string> visited_rows_a;
    std::unordered_set<std::string> visited_rows_b;
    
    if (use_indices)
    {
        unique_ids_a = unique_rows_to_combine(visited_rows_a, visited_shared_rows_a, a.m_labels, cat_inds_range_a,
                                              cat_inds_shared_a, cat_inds_a_only, mask_a, true, index_offset, status);
        CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
        
        unique_ids_b = unique_rows_to_combine(visited_rows_b, visited_shared_rows_b, b.m_labels, cat_inds_range_b,
                                              cat_inds_shared_b, cat_inds_b_only, mask_b, true, index_offset, status);
        CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
    }
    else
    {
        unique_ids_a = unique_rows_to_combine(visited_rows_a, visited_shared_rows_a, a.m_labels,
                                              cat_inds_range_a, cat_inds_shared_a, cat_inds_a_only, {}, false, 0, status);
        unique_ids_b = unique_rows_to_combine(visited_rows_b, visited_shared_rows_b, b.m_labels,
                                              cat_inds_range_b, cat_inds_shared_b, cat_inds_b_only, {}, false, 0, status);
    }
    
    util::categorical result = util::categorical::empty_copy(a);
    result.m_labels = std::move(unique_ids_a);
    
    for (const auto& cat_b : cats_b_only)
    {
        const u32 require_status = result.require_category(cat_b);
        CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(require_status)
    }
    
    //  Indices of categories of b in result.
    const std::vector<u64> cat_inds_b_only_result = result.get_category_indices_unchecked_has_category(cats_b_only);
    
    const std::vector<std::string> uniform_category_labels_a = get_uniform_category_labels(a, cats_a_only, mask_a,
                                                                                           use_indices, index_offset, status);
    CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
    
    const std::vector<std::string> uniform_category_labels_b = get_uniform_category_labels(b, cats_b_only, mask_b,
                                                                                           use_indices, index_offset, status);
    CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
    
    if (!cats_b_only.empty())
    {
        //  We must re-mark all the rows of result to include the missing categories of b.
        visited_rows_a.clear();
        const u64 num_unique_a = result.size();
        
        if (num_cats_shared > 0)
        {
            std::string row_hash_b = make_label_id_hash_string(num_cats_shared);
            
            for (u64 i = 0; i < num_unique_a; i++)
            {
                //  Build the search string for the row of shared category ids.
                const bool any_missing = build_union_row_hash(result, b, result.m_labels, &row_hash_b[0], i, cat_inds_shared_a);
                
                const auto it_shared_b = any_missing ? visited_shared_rows_b.end() : visited_shared_rows_b.find(row_hash_b);
                const auto it_shared_b_end = visited_shared_rows_b.end();
                
                for (u64 j = 0; j < num_cats_b_only; j++)
                {
                    std::string new_label;
                    //  b doesn't have this row of ids from shared categories.
                    //  Assign either collapsed expression or uniform label for each additional category of b.
                    if (it_shared_b == it_shared_b_end)
                    {
                        new_label = uniform_category_labels_b[j];
                    }
                    //  b has this row of ids from shared categories.
                    else
                    {
                        const VisitedRow& row = it_shared_b->second;
                        
                        //  This row of a is a strict subset of b, so copy the label from b. It will only be included once.
                        if (num_cats_a_only == 0)
                        {
                            const u32 id_b = unique_ids_b[cat_inds_b_only[j]][row.index_in_unique_matrix];
                            new_label = b.m_label_ids.at(id_b);
                        }
                        else
                        {
                            const s64 id_b = row.remaining_ids[j];
                            new_label = id_b == -1 ? uniform_category_labels_b[j] : b.m_label_ids.at(id_b);
                        }
                    }
                    
                    u32 assign_id;
                    const u32 add_status = result.add_label_unchecked_has_category(cats_b_only[j], new_label, &assign_id);
                    CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
                    
                    result.m_labels[cat_inds_b_only_result[j]][i] = assign_id;
                }
            }
        }
        //  Fill all with either collapsed expression or uniform label.
        else
        {
            for (u64 j = 0; j < num_cats_b_only; j++)
            {
                const std::string& new_label = uniform_category_labels_b[j];
                u32 assign_id;
                const u32 add_status = result.add_label_unchecked_has_category(cats_b_only[j], new_label, &assign_id);
                CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
                
                std::vector<u32>& id_column = result.m_labels[cat_inds_b_only_result[j]];
                std::fill(id_column.begin(), id_column.end(), assign_id);
            }
        }
        
        std::string complete_row_hash = make_label_id_hash_string(num_cats_total);
        char* complete_row_ptr = &complete_row_hash[0];
        
        //  Rehash.
        for (u64 i = 0; i < num_unique_a; i++)
        {
            //  Mark this row as complete
            build_row_hash(complete_row_ptr, result.m_labels, i, num_cats_total);
            visited_rows_a.emplace(complete_row_hash);
        }
    }
    
    const u64 num_unique_b = unique_ids_b.empty() ? 0 : unique_ids_b[0].size();
    std::vector<bool> mask_unique_ids_b;
    
    if (!cats_a_only.empty())
    {
        const u64 original_num_cats_b = unique_ids_b.size();
        
        //  Add additional columns for a.
        for (u64 i = 0; i < num_cats_a_only; i++)
        {
            std::vector<u32> cat_to_fill(num_unique_b);
            unique_ids_b.emplace_back(std::move(cat_to_fill));
        }
        
        if (num_cats_shared > 0)
        {
            //  In this case, we must indicate whether the row of b is a strict subset of a.
            mask_unique_ids_b.resize(num_unique_b);
            std::fill(mask_unique_ids_b.begin(), mask_unique_ids_b.end(), true);
            
            std::string row_hash_a = make_label_id_hash_string(num_cats_shared);
            
            for (u64 i = 0; i < num_unique_b; i++)
            {
                const bool any_missing = build_union_row_hash(b, result, unique_ids_b, &row_hash_a[0], i, cat_inds_shared_b);
                
                const auto it_shared_a_end = visited_shared_rows_a.end();
                const auto it_shared_a = any_missing ? it_shared_a_end : visited_shared_rows_a.find(row_hash_a);
                
                for (u64 j = 0; j < num_cats_a_only; j++)
                {
                    std::string new_label;
                    //  a doesn't have this row. Assign either collapsed expression or uniform label for each additional category of a.
                    if (it_shared_a == it_shared_a_end)
                    {
                        new_label = uniform_category_labels_a[j];
                    }
                    //  a has this row, and this row of b is a strict subset of a because b has no unique categories, so skip it.
                    else if (num_cats_b_only == 0)
                    {
                        mask_unique_ids_b[i] = false;
                        break;
                    }
                    else
                    {
                        const VisitedRow& row = it_shared_a->second;
                        const s64 id_a = row.remaining_ids[j];
                        new_label = id_a == -1 ? uniform_category_labels_a[j] : a.m_label_ids.at(id_a);
                    }
                    
                    u32 assign_id;
                    const u32 add_status = result.add_label_unchecked_has_category(cats_a_only[j], new_label, &assign_id);
                    CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)

                    unique_ids_b[original_num_cats_b+j][i] = assign_id;
                }
            }
        }
        //  Fill all with either collapsed expression or uniform label.
        else
        {
            for (u64 j = 0; j < num_cats_a_only; j++)
            {
                const std::string& new_label = uniform_category_labels_a[j];
                u32 assign_id;
                const u32 add_status = result.add_label_unchecked_has_category(cats_a_only[j], new_label, &assign_id);
                CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
                
                std::vector<u32>& id_column = unique_ids_b[original_num_cats_b+j];
                std::fill(id_column.begin(), id_column.end(), assign_id);
            }
        }
    }
    
    const bool same_progenitors = result.progenitors_match(b);
    
    std::string final_complete_hash = make_label_id_hash_string(num_cats_total);
    
    //  Now to append values to result as necessary.
    for (u64 i = 0; i < num_unique_b; i++)
    {
        //  If this row of b is a strict subset of a, skip it.
        if (!mask_unique_ids_b.empty() && !mask_unique_ids_b[i])
        {
            continue;
        }
        
        for (u64 j = 0; j < num_cats_shared; j++)
        {
            const u64 src_cat_ind = cat_inds_shared_b[j];
            const u64 dest_cat_ind = cat_inds_shared_a[j];
            
            const u32 id_b = unique_ids_b[src_cat_ind][i];
            u32 id_a;
            
            if (same_progenitors)
            {
                id_a = id_b;
            }
            else
            {
                const std::string& label = b.m_label_ids.ref_at(id_b);
                const u32 add_status = result.add_label_unchecked_has_category(cats_shared[j], label, &id_a);
                CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
            }
            
            std::memcpy(&final_complete_hash[0] + dest_cat_ind * sizeof(u32), &id_a, sizeof(u32));
        }
        
        for (u64 j = 0; j < num_cats_b_only; j++)
        {
            const u64 src_cat_ind = cat_inds_b_only[j];
            const u64 dest_cat_ind = cat_inds_b_only_result[j];
            
            const u32 id_b = unique_ids_b[src_cat_ind][i];
            u32 id_a;
            if (same_progenitors)
            {
                id_a = id_b;
            }
            else
            {
                const std::string& label = b.m_label_ids.ref_at(id_b);
                const u32 add_status = result.add_label_unchecked_has_category(cats_b_only[j], label, &id_a);
                CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
            }
            
            std::memcpy(&final_complete_hash[0] + dest_cat_ind * sizeof(u32), &id_a, sizeof(u32));
        }
        
        for (u64 j = 0; j < num_cats_a_only; j++)
        {
            const u64 src_cat_ind = j + num_cats_shared + num_cats_b_only;
            const u64 dest_cat_ind = cat_inds_a_only[j];
            
            const u32 id_a = unique_ids_b[src_cat_ind][i];
            
            std::memcpy(&final_complete_hash[0] + dest_cat_ind * sizeof(u32), &id_a, sizeof(u32));
        }
        
        if (visited_rows_a.count(final_complete_hash) == 0)
        {
            for (u64 j = 0; j < num_cats_shared; j++)
            {
                const u64 dest_cat_ind = cat_inds_shared_a[j];
                u32 id_a;
                std::memcpy(&id_a, &final_complete_hash[0] + dest_cat_ind * sizeof(u32), sizeof(u32));
                result.m_labels[dest_cat_ind].push_back(id_a);
            }
            for (u64 j = 0; j < num_cats_b_only; j++)
            {
                const u64 dest_cat_ind = cat_inds_b_only_result[j];
                u32 id_a;
                std::memcpy(&id_a, &final_complete_hash[0] + dest_cat_ind * sizeof(u32), sizeof(u32));
                result.m_labels[dest_cat_ind].push_back(id_a);
            }
            for (u64 j = 0; j < num_cats_a_only; j++)
            {
                const u64 src_cat_ind = j + num_cats_b_only + num_cats_shared;
                result.m_labels[cat_inds_a_only[j]].push_back(unique_ids_b[src_cat_ind][i]);
            }
            
            visited_rows_a.emplace(final_complete_hash);
        }
    }
    
    return result;
}


#if 0
namespace
{
    std::vector<std::vector<util::u32>> unique_rows(std::unordered_map<std::string, util::VisitedRow>& visited_rows,
                                                    const std::vector<std::vector<util::u32>>& ids,
                                                    const std::vector<util::u64>& category_indices,
                                                    const std::vector<util::u64>& remaining_category_indices,
                                                    const std::vector<util::u64>& indices,
                                                    const bool use_indices,
                                                    const util::u64 index_offset,
                                                    util::u32* status)
    {
        using util::u32;
        using util::u64;
        using util::s64;
        
        *status = util::categorical_status::OK;
        
        const u64 max_rows = ids.empty() ? 0 : ids[0].size();
        const u64 num_rows = use_indices ? indices.size() : max_rows;
        const u64 num_cols = category_indices.size();
        const u64 num_remaining_cols = remaining_category_indices.size();
        
        std::vector<std::vector<util::u32>> result;
        
        std::string row_hash;
        char* hash_ptr = nullptr;
        
        if (num_cols > 0 && num_rows > 0)
        {
            row_hash = make_label_id_hash_string(num_cols);
            hash_ptr = &row_hash[0];
            result.reserve(num_cols);
        }
        
        for (u64 i = 0; i < num_rows; i++)
        {
            u64 row_index = i;
            
            if (use_indices)
            {
                row_index = indices[i] - index_offset;
                
                if (row_index >= max_rows)
                {
                    *status = util::categorical_status::OUT_OF_BOUNDS;
                    return std::vector<std::vector<u32>>();
                }
            }
            
            build_row_hash(hash_ptr, ids, row_index, num_cols);
            
            if (visited_rows.count(row_hash) == 0)
            {
                //  Mark visited.
                const u64 unique_row_index = result.empty() ? 0 : result[0].size();
                visited_rows.emplace(row_hash, util::VisitedRow(unique_row_index, row_index));
                
                for (u64 j = 0; j < num_cols; j++)
                {
                    result[j].push_back(ids[category_indices[j]][row_index]);
                }
                
                //  Get the label ids for each remaining category.
                if (num_remaining_cols > 0)
                {
                    util::VisitedRow& row = visited_rows.at(row_hash);
                    std::vector<s64>& remaining_category_ids = row.remaining_ids;
                    
                    for (u64 j = 0; j < num_remaining_cols; j++)
                    {
                        const u32 remaining_id = ids[remaining_category_indices[j]][row_index];
                        remaining_category_ids.push_back(remaining_id);
                    }
                }
            }
            //  Otherwise, check whether we need to collapse a remaining category
            //  for this row.
            else if (num_remaining_cols > 0)
            {
                util::VisitedRow& row = visited_rows.at(row_hash);
                std::vector<s64>& remaining_category_ids = row.remaining_ids;
                
                for (u64 j = 0; j < num_remaining_cols; j++)
                {
                    const s64 present_id = remaining_category_ids[j];
                    
                    if (present_id != -1)
                    {
                        const u32 remaining_id = ids[remaining_category_indices[j]][row_index];
                        //  Label ids for a remaining category mismatch between unique rows,
                        //  so we must collapse the category. Indicate this with -1.
                        if (remaining_id != u32(present_id))
                        {
                            remaining_category_ids[j] = -1;
                        }
                    }
                }
            }
        }
        
        return result;
    }
    
    std::vector<std::vector<util::u32>> unique_rows(std::unordered_map<std::string, util::VisitedRow>& visited_rows,
                                                    const std::vector<std::vector<util::u32>>& ids,
                                                    const std::vector<util::u64>& category_indices,
                                                    const std::vector<util::u64>& rest_category_indices)
    {
        util::u32 dummy_status;
        return unique_rows(visited_rows, ids, category_indices, rest_category_indices,
                           std::vector<util::u64>(), false, 0, &dummy_status);
    }
    
    std::vector<std::string> union_sorted_categories(const std::vector<std::string>& cats_a,
                                                     const std::vector<std::string>& cats_b)
    {
        std::vector<std::string> categories;
        std::set_union(cats_a.begin(), cats_a.end(),
                       cats_b.begin(), cats_b.end(), std::back_inserter(categories));
        
        return categories;
    }
    
    std::vector<std::string> shared_categories(const util::categorical& a, const util::categorical& b)
    {
        std::vector<std::string> cats_a = a.get_categories();
        std::vector<std::string> cats_b = b.get_categories();
        return intersecting_sorted_categories(cats_a, cats_b);
    }
    
    void keep_categories_unchecked_has_categories(util::categorical& a, const std::vector<std::string>& categories)
    {
        std::vector<std::string> to_remove = a.get_categories_except(categories);
        
        for (const auto& category : to_remove)
        {
            bool dummy_exists;
            a.remove_category(category, &dummy_exists);
        }
    }
    
    std::vector<util::u64> linear_category_search(const std::vector<std::string>& subset,
                                                  const std::vector<std::string>& full_set)
    {
        const util::u64 num_subset = subset.size();
        const util::u64 num_full_set = full_set.size();
        std::vector<util::u64> result(num_subset);
        
        for (util::u64 i = 0; i < num_subset; i++)
        {
            const std::string& cat = subset[i];
            result[i] = 0;
            
            for (util::u64 j = 0; j < num_full_set; j++)
            {
                if (full_set[j] == cat)
                {
                    break;
                }
                
                result[i]++;
            }
        }
        
        return result;
    }
}

util::categorical util::categorical::set_union_impl(const util::categorical& a,
                                                    const util::categorical& b,
                                                    util::u32* status,
                                                    const std::vector<std::string>& categories,
                                                    const std::vector<util::u64>& mask_a,
                                                    const std::vector<util::u64>& mask_b,
                                                    const util::u64 index_offset,
                                                    const bool use_indices)
{
    *status = categorical_status::OK;
    
    if (!a.has_categories(categories) || !b.has_categories(categories))
    {
        *status = categorical_status::CATEGORY_DOES_NOT_EXIST;
        return util::categorical();
    }
    
    util::categorical result;
    
    const u64 num_cats_in = categories.size();
    const u64 num_rows_a = use_indices ? mask_a.size() : a.size();
    const u64 num_rows_b = use_indices ? mask_b.size() : b.size();
    
    const std::vector<std::string> remaining_categories_a = a.get_categories_except(categories);
    const std::vector<std::string> remaining_categories_b = b.get_categories_except(categories);
    const std::vector<std::string> remaining_categories = union_sorted_categories(remaining_categories_a, remaining_categories_b);
    
    const std::vector<u64> rest_cat_indices_b_to_a = linear_category_search(remaining_categories_b, remaining_categories_a);
    const std::vector<u64> rest_cat_indices_a_to_b = linear_category_search(remaining_categories_a, remaining_categories_b);
    
    const u64 num_cats_remaining_a = remaining_categories_a.size();
    const u64 num_cats_remaining_b = remaining_categories_b.size();
    
    std::vector<std::vector<util::u32>> unique_ids_a;
    std::vector<std::vector<util::u32>> unique_ids_b;
    bool dummy_exists;
    
    const std::vector<u64> cat_indices_a = a.get_category_indices_unchecked_has_category(categories);
    const std::vector<u64> rest_cat_indices_a = a.get_category_indices_unchecked_has_category(remaining_categories_a);
    
    const std::vector<u64> cat_indices_b = b.get_category_indices_unchecked_has_category(categories);
    const std::vector<u64> rest_cat_indices_b = b.get_category_indices_unchecked_has_category(remaining_categories_b);
    
    //  Store the unique label ids of a.
    std::unordered_map<std::string, VisitedRow> visited_rows_a;
    std::unordered_map<std::string, VisitedRow> visited_rows_b;
    
    if (use_indices)
    {
        unique_ids_a = unique_rows(visited_rows_a, a.m_labels, cat_indices_a, rest_cat_indices_a,
                                   mask_a, true, index_offset, status);
        if (*status != categorical_status::OK)
        {
            return util::categorical();
        }
        
        unique_ids_b = unique_rows(visited_rows_b, b.m_labels, cat_indices_b, rest_cat_indices_b,
                                   mask_b, true, index_offset, status);
        if (*status != categorical_status::OK)
        {
            return util::categorical();
        }
    }
    else
    {
        unique_ids_a = unique_rows(visited_rows_a, a.m_labels, cat_indices_a, rest_cat_indices_a);
        unique_ids_b = unique_rows(visited_rows_b, b.m_labels, cat_indices_b, rest_cat_indices_b);
    }
    
    //  Start with a as a template, but retain only `categories`.
    result = empty_copy(a);
    keep_categories_unchecked_has_categories(result, categories);
    
    //  Now overwrite the label id matrix for a, and update the category
    //  indices for a.
    result.m_labels = std::move(unique_ids_a);
    
    for (u64 i = 0; i < num_cats_in; i++)
    {
        result.m_category_indices[categories[i]] = i;
        
        if (result.m_labels.size() <= i)
        {
            result.m_labels.push_back(std::vector<u32>());
        }
    }
    
    result.prune();
    
    //  Now add back in all categories.
    for (const auto& category : remaining_categories)
    {
        const u32 require_status = result.require_category(category);
        if (require_status != categorical_status::OK)
        {
            *status = require_status;
            return util::categorical();
        }
    }
    
    //  Keep track of whether we need to reassign label ids.
    const bool same_progenitors = result.progenitors_match(b);
    
    //  For every row in unique_ids_b, see if it exists in unique_ids_a. If not,
    //  add it to result, and for remaining categories, set according to b. If it does exist,
    //  first remove it from the set of rows of a that need to be subsequently analyzed. Then
    //  for remaining shared categories, if the label is -1 in either a or b, or the label associated with the id
    //  does not match between a and b, assign the collapsed expression, otherwise assign the label.
    //  For the remaining unmarked rows of a, assign the remaining categories according to the values in a.
    
    std::vector<bool> are_uniform_a;
    std::vector<bool> are_uniform_b;
    
    const u64 row0_a = num_rows_a == 0 ? 0 : use_indices ? (mask_a[0] - index_offset) : 0;
    const u64 row0_b = num_rows_b == 0 ? 0 : use_indices ? (mask_b[0] - index_offset) : 0;
    
    if (use_indices)
    {
        are_uniform_a = a.are_uniform_categories(remaining_categories_a, mask_a, status, index_offset);
        if (*status != categorical_status::OK)
        {
            return util::categorical();
        }
        
        are_uniform_b = b.are_uniform_categories(remaining_categories_b, mask_b, status, index_offset);
        if (*status != categorical_status::OK)
        {
            return util::categorical();
        }
    }
    else
    {
        are_uniform_a = a.are_uniform_categories(remaining_categories_a, &dummy_exists);
        are_uniform_b = b.are_uniform_categories(remaining_categories_b, &dummy_exists);
    }
    
    const auto rest_cat_inds_a_in_result = result.get_category_indices_unchecked_has_category(remaining_categories_a);
    const auto rest_cat_inds_b_in_result = result.get_category_indices_unchecked_has_category(remaining_categories_b);
    
    const u64 num_rows_result = result.size();
    const u64 num_rows_unique_b = unique_ids_b.empty() ? 0 : unique_ids_b[0].size();
    
    //  Hash of a unique row of b in terms of a.
    std::string hash_b_to_a = make_label_id_hash_string(num_cats_in);
    std::string hash_b_to_b = make_label_id_hash_string(num_cats_in);
    
    char* hash_b_to_a_ptr = num_cats_in == 0 ? nullptr : &hash_b_to_a[0];
    char* hash_b_to_b_ptr = num_cats_in == 0 ? nullptr : &hash_b_to_b[0];
    
    std::unordered_map<u32, u32> visited_ids_b;
    std::vector<uint8_t> marked_rows_result;
    
    if (num_rows_result > 0)
    {
        marked_rows_result.resize(num_rows_result);
        std::fill(marked_rows_result.begin(), marked_rows_result.end(), 0);
    }
    
    //  Loop over unique rows of b.
    for (u64 i = 0; i < num_rows_unique_b; i++)
    {
        bool any_new_labels = false;
        
        if (same_progenitors)
        {
            build_row_hash(hash_b_to_a_ptr, unique_ids_b, i, num_cats_in);
            //  b_to_b same as b_to_a
            std::memcpy(hash_b_to_b_ptr, hash_b_to_a_ptr, sizeof(u32) * num_cats_in);
        }
        else
        {
            //  Check to see whether result has each label of a row of b. If there are any new labels,
            //  then this must be a new unique row. Otherwise, we must check whether the row is new.
            for (u64 j = 0; j < num_cats_in; j++)
            {
                u32 id_a;
                const u32 id_b = unique_ids_b[j][i];
                const std::string& label_b = b.m_label_ids.ref_at(id_b);
                
                if (!result.m_label_ids.contains(label_b))
                {
                    any_new_labels = true;
                    id_a = 0;
                }
                else
                {
                    id_a = result.m_label_ids.at(label_b);
                }
                
                std::memcpy(hash_b_to_a_ptr + j*sizeof(u32), &id_a, sizeof(u32));
                std::memcpy(hash_b_to_b_ptr + j*sizeof(u32), &id_b, sizeof(u32));
            }
        }
        
        const auto it_a = any_new_labels ? visited_rows_a.end() : visited_rows_a.find(hash_b_to_a);
        
        //  This is a new row (not in unique_ids_a)
        if (it_a == visited_rows_a.end())
        {
            //  Assign values to categories in the inputted categories.
            for (u64 j = 0; j < num_cats_in; j++)
            {
                const u32 id_b = unique_ids_b[j][i];
                u32 reconcile_status;
                const u32 id_result = reconcile_label_id(result, b, categories[j], id_b, visited_ids_b, &reconcile_status, true);
                
                if (reconcile_status != categorical_status::OK)
                {
                    *status = reconcile_status;
                    return util::categorical();
                }
                //  Input categories are first N categories.
                result.m_labels[j].push_back(id_result);
            }
            
            //  Next assign values from additional categories in b not specified in the given input categories.
            const std::vector<s64>& remaining_ids = visited_rows_b.at(hash_b_to_b).remaining_ids;
            
            for (u64 j = 0; j < num_cats_remaining_b; j++)
            {
                const std::string& remaining_category = remaining_categories_b[j];
                const s64 id_b = remaining_ids[j];
                const std::string assigned_label = id_b == -1 ?
                result.get_collapsed_expression(remaining_category) : b.m_label_ids.at(id_b);
                
                const u32 add_status = result.add_label_unchecked_has_category(remaining_category, assigned_label, true);
                if (add_status != categorical_status::OK)
                {
                    *status = add_status;
                    return util::categorical();
                }
                
                const u32 new_id = result.m_label_ids.at(assigned_label);
                result.m_labels[rest_cat_inds_b_in_result[j]].push_back(new_id);
            }
            
            //  Assign values from the remaining categories of a not already assigned from b.
            //  Because this is a new row from a's perspective, we can only use either the collapsed
            //  expression for a, or the single unique value in a.
            for (u64 j = 0; j < num_cats_remaining_a; j++)
            {
                const std::string& remaining_category = remaining_categories_a[j];
                
                if (!b.has_category(remaining_category))
                {
                    u32 assign_status;
                    const u32 assign_label_id = result.remaining_unique_category_label_id(a, remaining_category, are_uniform_a[j],
                                                                                          rest_cat_indices_a[j], num_rows_a, row0_a, &assign_status);
                    if (assign_status != categorical_status::OK)
                    {
                        *status = assign_status;
                        return util::categorical();
                    }
                    
                    result.m_labels[rest_cat_inds_a_in_result[j]].push_back(assign_label_id);
                }
            }
        }
        //  Otherwise, this row already exists in unique_ids_a, but we need to fill in the remaining
        //  categories.
        else
        {
            const VisitedRow& visited_row_a = it_a->second;
            const VisitedRow& visited_row_b = visited_rows_b.at(hash_b_to_b);
            const u64 dest_row_index = visited_row_a.index_in_unique_matrix;
            
            const std::vector<s64>& remaining_ids_a = visited_row_a.remaining_ids;
            const std::vector<s64>& remaining_ids_b = visited_row_b.remaining_ids;
            
            marked_rows_result[dest_row_index] = 1;
            
            for (u64 j = 0; j < num_cats_remaining_a; j++)
            {
                const std::string& remaining_category = remaining_categories_a[j];
                const s64 id_a = remaining_ids_a[j];
                std::string assign_label;
                
                //  We already know to use the collapsed expression for this category.
                if (id_a == -1)
                {
                    assign_label = result.get_collapsed_expression(remaining_category);
                }
                //  B has this category, so we must see whether the value of it in remaining_ids_b is the same.
                else if (b.has_category(remaining_category))
                {
                    const u64 rest_cat_ind_b = rest_cat_indices_a_to_b[j];
                    const s64 id_b = remaining_ids_b[rest_cat_ind_b];
                    //  We must use the collapsed expression.
                    if (id_b == -1)
                    {
                        assign_label = result.get_collapsed_expression(remaining_category);
                    }
                    else
                    {
                        const std::string& label_a = a.m_label_ids.ref_at(id_a);
                        const std::string& label_b = b.m_label_ids.ref_at(u32(id_b));
                        //  If the labels are the same, assign it, otherwise we must use the collapsed expression.
                        assign_label = label_a == label_b ? label_a : result.get_collapsed_expression(remaining_category);
                    }
                }
                //  The value is the non-collapsed value for a.
                else
                {
                    assign_label = a.m_label_ids.at(id_a);
                }
                
                const u64 assign_status = result.add_label_unchecked_has_category(remaining_category, assign_label, true);
                if (assign_status != categorical_status::OK)
                {
                    *status = assign_status;
                    return util::categorical();
                }
                
                const u32 id_result = result.m_label_ids.at(assign_label);
                result.m_labels[rest_cat_inds_a_in_result[j]][dest_row_index] = id_result;
            }
            
            //  Fill in categories according to b.
            for (u64 j = 0; j < num_cats_remaining_b; j++)
            {
                const std::string& remaining_category = remaining_categories_b[j];
                //  Already accounted for above.
                if (a.has_category(remaining_category))
                {
                    continue;
                }
                
                const s64 id_b = remaining_ids_b[j];
                const std::string assign_label = id_b == -1 ? result.get_collapsed_expression(remaining_category) : b.m_label_ids.at(id_b);
                
                const u64 assign_status = result.add_label_unchecked_has_category(remaining_category, assign_label, true);
                if (assign_status != categorical_status::OK)
                {
                    *status = assign_status;
                    return util::categorical();
                }
                
                const u32 id_result = result.m_label_ids.at(assign_label);
                result.m_labels[rest_cat_inds_b_in_result[j]][dest_row_index] = id_result;
            }
        }
    }
    
    //  Loop rows that are unique to a, i.e., that b does not have. For remaining categories in a,
    //  assign according to a. For remaining categories of b, use either the collapsed expression or the single unique
    //  label.
    for (u64 i = 0; i < num_rows_result; i++)
    {
        if (marked_rows_result[i])
        {
            continue;
        }
        
        build_row_hash(hash_b_to_a_ptr, result.m_labels, i, num_cats_in);
        const auto it_a = visited_rows_a.find(hash_b_to_a);
        const VisitedRow& row = it_a->second;
        const u64 dest_row_index = row.index_in_unique_matrix;
        
        for (u64 j = 0; j < num_cats_remaining_a; j++)
        {
            const std::string& remaining_category = remaining_categories_a[j];
            const s64 id_a = row.remaining_ids[j];
            const std::string assign_label = id_a == -1 ? result.get_collapsed_expression(remaining_category) : a.m_label_ids.at(id_a);
            
            const u64 assign_status = result.add_label_unchecked_has_category(remaining_category, assign_label, true);
            if (assign_status != categorical_status::OK)
            {
                *status = assign_status;
                return util::categorical();
            }
            
            const u32 id_result = result.m_label_ids.at(assign_label);
            const u64 dest_cat_ind = rest_cat_inds_a_in_result[j];
            result.m_labels[dest_cat_ind][dest_row_index] = id_result;
        }
        
        for (u64 j = 0; j < num_cats_remaining_b; j++)
        {
            const std::string& remaining_category = remaining_categories_b[j];
            if (!a.has_category(remaining_category))
            {
                u32 assign_status;
                const u32 assign_label_id = result.remaining_unique_category_label_id(b, remaining_category, are_uniform_b[j],
                                                                                      rest_cat_indices_b[j], num_rows_b, row0_b, &assign_status);
                if (assign_status != categorical_status::OK)
                {
                    *status = assign_status;
                    return util::categorical();
                }
                
                result.m_labels[rest_cat_inds_b_in_result[j]][dest_row_index] = assign_label_id;
            }
        }
    }
    
    return result;
}
#endif

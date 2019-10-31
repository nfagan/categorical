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
    std::vector<util::u64> make_range(const util::u64 n)
    {
        std::vector<util::u64> result(n);
        
        for (util::u64 i = 0; i < n; i++)
        {
            result[i] = i;
        }
        
        return result;
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
    
    std::vector<std::string> union_sorted_categories(const std::vector<std::string>& cats_a,
                                                     const std::vector<std::string>& cats_b)
    {
        std::vector<std::string> categories;
        std::set_union(cats_a.begin(), cats_a.end(),
                       cats_b.begin(), cats_b.end(), std::back_inserter(categories));
        
        return categories;
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
            
            if (visited_complete_rows.count(row_hash) == 0)
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
}

util::set_unique::set_unique(const util::categorical& a) : base(), a(a)
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

util::set_union::set_union(const util::categorical& a, const util::categorical& b, const set_membership::options& opts) :
base(opts), a(a), b(b)
{
    //
}

std::vector<std::vector<util::u32>> util::set_union::unique_rows_to_combine(std::unordered_set<std::string>& visited_complete_rows,
                                                                            std::unordered_map<std::string, util::VisitedRow>& visited_shared_rows,
                                                                            const std::vector<std::vector<util::u32>>& ids,
                                                                            const std::vector<util::u64>& category_indices,
                                                                            const std::vector<util::u64>& shared_category_indices,
                                                                            const std::vector<util::u64>& unique_category_indices,
                                                                            const std::vector<util::u64>& indices,
                                                                            const bool use_indices,
                                                                            util::u32* status) const
{
    *status = util::categorical_status::OK;
    
    const u64 num_categories = category_indices.size();
    const u64 num_shared = shared_category_indices.size();
    const u64 num_unique = unique_category_indices.size();
    const u64 max_rows = num_rows_in_matrix(ids);
    const u64 num_rows = use_indices ? indices.size() : max_rows;
    const u64 index_offset = options.index_offset;
    
    std::vector<std::vector<util::u32>> result(num_categories);
    
    std::string complete_row_hash = make_label_id_hash_string(num_categories);
    std::string shared_row_hash = make_label_id_hash_string(num_shared);
    
    u64 unique_row_index = 0;
    
    for (u64 i = 0; i < num_rows; i++)
    {
        const u64 row_index = use_indices ? indices[i] - index_offset : i;
        
        if (row_index >= max_rows)
        {
            *status = util::categorical_status::OUT_OF_BOUNDS;
            return {};
        }
        
        util::build_row_hash(&complete_row_hash[0], ids, row_index, category_indices);
        util::build_row_hash(&shared_row_hash[0], ids, row_index, shared_category_indices);
        
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
        
        const auto visited_shared_it = visited_shared_rows.find(shared_row_hash);
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
        
        ::util::build_row_hash(&row_hash[0], ids_b, row, num_cols);
        
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

bool util::set_union::build_row_hash(const util::categorical& a,
                                     const util::categorical& b,
                                     const std::vector<std::vector<u32>>& a_label_matrix,
                                     char* row_hash_ptr,
                                     const util::u64 row,
                                     const std::vector<util::u64>& src_category_indices,
                                     const std::vector<util::u64>& dest_category_indices)
{
    bool any_missing = false;
    
    if (a.progenitors_match(b))
    {
        ::util::build_row_hash(row_hash_ptr, a_label_matrix, row, src_category_indices);
    }
    else
    {
        const u64 num_cats = src_category_indices.size();
        for (u64 j = 0; j < num_cats; j++)
        {
            const std::string& label = a.m_label_ids.ref_at(a_label_matrix[src_category_indices[j]][row]);
            const auto& it_b = b.m_label_ids.find(label);
            
            //  Okay - use the b's label id to search.
            if (it_b != b.m_label_ids.endk())
            {
                const u32 id_b = it_b->second;
                std::memcpy(row_hash_ptr + dest_category_indices[j] * sizeof(u32), &id_b, sizeof(u32));
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
    const std::vector<std::string> categories = union_sorted_categories(a.get_categories(), b.get_categories());
    return set_combination_impl(status, categories, categories, {}, {}, false);
}

util::categorical util::set_union::make_combined(const std::vector<util::u64>& mask_a,
                                                 const std::vector<util::u64>& mask_b,
                                                 util::u32* status) const
{
    const std::vector<std::string> categories = union_sorted_categories(a.get_categories(), b.get_categories());
    return set_combination_impl(status, categories, categories, mask_a, mask_b, true);
}

util::categorical util::set_union::make_union(util::u32* status) const
{
    if (!a.categories_match(b))
    {
        *status = categorical_status::CATEGORIES_DO_NOT_MATCH;
        return util::categorical();
    }
    
    return set_union_impl(status, a.get_categories(), {}, {}, false);
}

util::categorical util::set_union::make_union(const std::vector<util::u64>& mask_a,
                                              const std::vector<util::u64>& mask_b,
                                              util::u32* status) const
{
    if (!a.categories_match(b))
    {
        *status = categorical_status::CATEGORIES_DO_NOT_MATCH;
        return util::categorical();
    }
    
    return set_union_impl(status, a.get_categories(), mask_a, mask_b, true);
}

util::categorical util::set_union::make_union(const std::vector<std::string>& categories, util::u32* status) const
{
    return set_union_impl(status, categories, {}, {}, false);
}

util::categorical util::set_union::make_union(const std::vector<std::string>& categories,
                                              const std::vector<util::u64>& mask_a,
                                              const std::vector<util::u64>& mask_b,
                                              util::u32* status) const
{
    return set_union_impl(status, categories, mask_a, mask_b, true);
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
                                                                      const bool use_indices) const
{
    const std::vector<u64> cat_inds_a = a.get_category_indices_unchecked_has_category(categories);
    const std::vector<u64> cat_inds_b = b.get_category_indices_unchecked_has_category(categories);
    const u64 index_offset = options.index_offset;
    
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
                                                  const bool use_indices) const
{
    *status = categorical_status::OK;
    
    if (!a.has_categories(in_categories) || !b.has_categories(in_categories))
    {
        *status = categorical_status::CATEGORY_DOES_NOT_EXIST;
        return util::categorical();
    }
    
    const std::vector<std::string> categories = unique_categories(in_categories);
    //  Fast path when categories are the same between a and b, and all categories are specified in categories.
    if (categories.size() == a.n_categories() && categories.size() == b.n_categories())
    {
        return set_union_impl_matching_categories(status, categories, mask_a, mask_b, use_indices);
    }
    
    return set_combination_impl(status, categories, categories, mask_a, mask_b, use_indices);
}

util::categorical util::set_union::set_combination_impl(util::u32* status,
                                                        const std::vector<std::string>& cats_final,
                                                        const std::vector<std::string>& cats_compute_union,
                                                        const std::vector<util::u64>& mask_a,
                                                        const std::vector<util::u64>& mask_b,
                                                        const bool use_indices) const
{
    const auto all_cats_a = a.get_categories();
    const auto all_cats_b = b.get_categories();
    
    const auto all_cats_only_a = set_difference_sorted_categories(all_cats_a, all_cats_b);
    const auto all_cats_only_b = set_difference_sorted_categories(all_cats_b, all_cats_a);
    
    //  Cats unique to a and b in result.
    const auto final_cats_only_a = intersecting_sorted_categories(cats_final, all_cats_only_a);
    const auto final_cats_only_b = intersecting_sorted_categories(cats_final, all_cats_only_b);
    
    //  Cats unique to a and b used to compute unique rows of each, respectively.
    const auto union_cats_only_a = intersecting_sorted_categories(cats_compute_union, all_cats_only_a);
    const auto union_cats_only_b = intersecting_sorted_categories(cats_compute_union, all_cats_only_b);
    
    const auto cats_to_remove_a = set_difference_sorted_categories(all_cats_a, cats_final);
    
    const auto union_cats_a = intersecting_sorted_categories(cats_compute_union, all_cats_a);
    const auto union_cats_b = intersecting_sorted_categories(cats_compute_union, all_cats_b);
    const auto shared_union_cats = intersecting_sorted_categories(union_cats_a, union_cats_b);
    
    const auto check_collapse_a = set_difference_sorted_categories(final_cats_only_a, union_cats_a);
    const auto check_collapse_b = set_difference_sorted_categories(final_cats_only_b, union_cats_b);
    
    auto cat_inds_union_a = a.get_category_indices_unchecked_has_category(union_cats_a);
    auto cat_inds_union_b = b.get_category_indices_unchecked_has_category(union_cats_b);
    
    auto cat_inds_shared_a = a.get_category_indices_unchecked_has_category(shared_union_cats);
    auto cat_inds_shared_b = b.get_category_indices_unchecked_has_category(shared_union_cats);
    
    auto cat_inds_final_only_a = a.get_category_indices_unchecked_has_category(final_cats_only_a);
    auto cat_inds_final_only_b = b.get_category_indices_unchecked_has_category(final_cats_only_b);
    
    const u64 num_cats_final = cats_final.size();
    const u64 num_cats_final_only_a = final_cats_only_a.size();
    const u64 num_cats_final_only_b = final_cats_only_b.size();
    const u64 num_shared_union_cats = shared_union_cats.size();
    
    const auto cat_inds_shared_range = make_range(num_shared_union_cats);
    
    std::unordered_map<std::string, VisitedRow> visited_shared_rows_a;
    std::unordered_map<std::string, VisitedRow> visited_shared_rows_b;
    
    std::unordered_set<std::string> visited_rows_a;
    std::unordered_set<std::string> visited_rows_b;
    
    std::vector<std::vector<util::u32>> unique_ids_a = unique_rows_to_combine(visited_rows_a, visited_shared_rows_a,
                                                                              a.m_labels, cat_inds_union_a,
                                                                              cat_inds_shared_a, cat_inds_final_only_a,
                                                                              mask_a, use_indices, status);
    CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
    std::vector<std::vector<util::u32>> unique_ids_b = unique_rows_to_combine(visited_rows_b, visited_shared_rows_b,
                                                                              b.m_labels, cat_inds_union_b,
                                                                              cat_inds_shared_b, cat_inds_final_only_b,
                                                                              mask_b, use_indices, status);
    CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
    
    //  Get labels for categories unique to a or b.
    const std::vector<std::string> uniform_category_labels_a = get_uniform_category_labels(a, final_cats_only_a, mask_a,
                                                                                           use_indices, options.index_offset, status);
    CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
    
    const std::vector<std::string> uniform_category_labels_b = get_uniform_category_labels(b, final_cats_only_b, mask_b,
                                                                                           use_indices, options.index_offset, status);
    CAT_CHECK_STATUS_PTR_EARLY_RETURN_CATEGORICAL()
    
    //  Build result template.
    categorical result = categorical::empty_copy(a);
    
    //  Remove categories not in cats_final
    for (const auto& cat : cats_to_remove_a)
    {
        bool ignore_exists;
        result.remove_category(cat, &ignore_exists);
    }
    
    //  Remap computed union categories to first N-1.
    for (u64 i = 0; i < union_cats_a.size(); i++)
    {
        result.m_category_indices[union_cats_a[i]] = i;
    }
    
    result.m_labels = std::move(unique_ids_a);
    
    //  Add categories unique to b.
    for (const auto& cat : final_cats_only_b)
    {
        const u32 require_status = result.require_category(cat);
        CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(require_status)
    }
    
    //  Remap category indices.
    cat_inds_union_a = make_range(union_cats_a.size());
    
    const auto cat_inds_shared_in_unique_ids_b = linear_category_search(shared_union_cats, union_cats_b);
    const auto cat_inds_final_only_b_result = result.get_category_indices_unchecked_has_category(final_cats_only_b);
    const auto cat_inds_shared_result = result.get_category_indices_unchecked_has_category(shared_union_cats);
    const auto cat_inds_final_result = result.get_category_indices_unchecked_has_category(cats_final);
    const auto cat_inds_final_range = make_range(num_cats_final);
    
    const u64 num_rows_unique_a = result.size();
    
    //  Fill in columns of a unique to b.
    if (num_cats_final_only_b > 0)
    {
        visited_rows_a.clear();
        
        if (num_shared_union_cats > 0)
        {
            std::string shared_hash = make_label_id_hash_string(num_shared_union_cats);
            
            for (u64 i = 0; i < num_rows_unique_a; i++)
            {
                //  Build hash from a -> b. Read from cat_inds_shared_result, write to 0:N-1 (cat_inds_shared).
                const bool any_missing = build_row_hash(result, b, result.m_labels, &shared_hash[0], i, cat_inds_shared_result, cat_inds_shared_range);
                //  Does b have this shared row?
                const auto it_shared_b = any_missing ? visited_shared_rows_b.end() : visited_shared_rows_b.find(shared_hash);
                const auto it_shared_b_end = visited_shared_rows_b.end();
                
                for (u64 j = 0; j < num_cats_final_only_b; j++)
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
                        const s64 id_b = row.remaining_ids[j];
                        new_label = id_b == -1 ? uniform_category_labels_b[j] : b.m_label_ids.at(id_b);
                    }
                    
                    u32 assign_id;
                    const u32 add_status = result.add_label_unchecked_has_category(final_cats_only_b[j], new_label, &assign_id);
                    CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
                    result.m_labels[cat_inds_final_only_b_result[j]][i] = assign_id;
                }
            }
        }
        else
        {
            for (u64 j = 0; j < num_cats_final_only_b; j++)
            {
                const std::string& new_label = uniform_category_labels_b[j];
                u32 assign_id;
                const u32 add_status = result.add_label_unchecked_has_category(final_cats_only_b[j], new_label, &assign_id);
                CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
                
                std::vector<u32>& id_column = result.m_labels[cat_inds_final_only_b_result[j]];
                std::fill(id_column.begin(), id_column.end(), assign_id);
            }
        }
        
        std::string complete_row_hash = make_label_id_hash_string(num_cats_final);
        
        //  Rehash.
        for (u64 i = 0; i < num_rows_unique_a; i++)
        {
            //  Mark this row as complete. Read from cat_inds_final_result, write to 0:N-1.
            ::util::build_row_hash(&complete_row_hash[0], result.m_labels, i, cat_inds_final_result, cat_inds_final_result);
            visited_rows_a.emplace(complete_row_hash);
        }
    }
    
    const u64 num_unique_b = num_rows_in_matrix(unique_ids_b);
    const u64 original_num_cats_b = unique_ids_b.size();
    
    if (num_cats_final_only_a > 0)
    {
        //  Add additional columns for a.
        for (u64 i = 0; i < num_cats_final_only_a; i++)
        {
            add_column(unique_ids_b);
        }
        
        if (num_shared_union_cats > 0)
        {
            std::string row_hash_a = make_label_id_hash_string(num_shared_union_cats);
            
            for (u64 i = 0; i < num_unique_b; i++)
            {
                //  Build hash from b -> a. Read from cat_inds_shared_in_unique_ids_b, write to 0:N-1 (cat_inds_shared).
                const bool any_missing = build_row_hash(b, result, unique_ids_b, &row_hash_a[0], i, cat_inds_shared_in_unique_ids_b, cat_inds_shared_range);
                
                const auto it_shared_a_end = visited_shared_rows_a.end();
                const auto it_shared_a = any_missing ? it_shared_a_end : visited_shared_rows_a.find(row_hash_a);
                
                for (u64 j = 0; j < num_cats_final_only_a; j++)
                {
                    std::string new_label;
                    //  a doesn't have this row. Assign either collapsed expression or uniform label for each additional category of a.
                    if (it_shared_a == it_shared_a_end)
                    {
                        new_label = uniform_category_labels_a[j];
                    }
                    else
                    {
                        const VisitedRow& row = it_shared_a->second;
                        const s64 id_a = row.remaining_ids[j];
                        new_label = id_a == -1 ? uniform_category_labels_a[j] : a.m_label_ids.at(id_a);
                    }
                    
                    u32 assign_id;
                    const u32 add_status = result.add_label_unchecked_has_category(final_cats_only_a[j], new_label, &assign_id);
                    CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
                    
                    unique_ids_b[original_num_cats_b+j][i] = assign_id;
                }
            }
        }
        else
        {
            for (u64 j = 0; j < num_cats_final_only_a; j++)
            {
                const std::string& new_label = uniform_category_labels_a[j];
                u32 assign_id;
                const u32 add_status = result.add_label_unchecked_has_category(final_cats_only_a[j], new_label, &assign_id);
                CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
                
                std::vector<u32>& id_column = unique_ids_b[original_num_cats_b+j];
                std::fill(id_column.begin(), id_column.end(), assign_id);
            }
        }
    }
    
    std::string final_complete_hash = make_label_id_hash_string(num_cats_final);
    
    std::vector<util::u64> cat_inds_final_b;
    std::vector<bool> is_only_a;
    
    for (const auto& cat : cats_final)
    {
        const auto ind = std::find(union_cats_b.begin(), union_cats_b.end(), cat);
        
        if (ind == union_cats_b.end())
        {
            const auto a_only_ind = std::find(final_cats_only_a.begin(), final_cats_only_a.end(), cat);
            cat_inds_final_b.push_back(a_only_ind - final_cats_only_a.begin() + original_num_cats_b);
            is_only_a.push_back(true);
        }
        else
        {
            cat_inds_final_b.push_back(ind - union_cats_b.begin());
            is_only_a.push_back(false);
        }
    }
    
    //  Now to append values to result as necessary.
    for (u64 i = 0; i < num_unique_b; i++)
    {
        for (u64 j = 0; j < num_cats_final; j++)
        {
            u32 id_a;
            const u32 id_b = unique_ids_b[cat_inds_final_b[j]][i];
            
            if (!is_only_a[j])
            {
                const std::string& label = b.m_label_ids.ref_at(id_b);
                const u32 add_status = result.add_label_unchecked_has_category(cats_final[j], label, &id_a);
                CAT_CHECK_STATUS_ASSIGN_STATUS_EARLY_RETURN_CATEGORICAL(add_status)
            }
            else
            {
                id_a = id_b;
            }
            
            std::memcpy(&final_complete_hash[0] + cat_inds_final_result[j]*sizeof(u32), &id_a, sizeof(u32));
        }
        
        const bool is_new_row = visited_rows_a.count(final_complete_hash) == 0;
        
        if (is_new_row)
        {
            visited_rows_a.emplace(final_complete_hash);
            
            for (u64 j = 0; j < num_cats_final; j++)
            {
                const u64 dest_ind = cat_inds_final_result[j];
                u32 id_a;
                std::memcpy(&id_a, &final_complete_hash[0] + dest_ind*sizeof(u32), sizeof(u32));
                result.m_labels[dest_ind].push_back(id_a);
            }
        }
    }
    
    return result;
}

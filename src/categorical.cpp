//
//  categorical.cpp
//  categorical
//
//  Created by Nick Fagan on 3/20/18.
//

#include "categorical.hpp"
#include "helpers.hpp"
#include "hashing.hpp"
#include <random>
#include <iostream>
#include <algorithm>
#include <numeric>
#include <cstring>

//  !=: Check for inequality.

bool util::categorical::operator !=(const util::categorical& other) const
{
    return !(util::categorical::operator ==(other));
}

//  unchecked_eq_progenitors_match: Check for equality, assuming progenitors and sizes match.

bool util::categorical::unchecked_eq_progenitors_match(const util::categorical& other, util::u64 sz) const
{
    u64 n_cats = m_labels.size();
    
    for (u64 i = 0; i < n_cats; i++)
    {
        const u32* own_ptr = m_labels[i].data();
        const u32* other_ptr = other.m_labels[i].data();
        const std::size_t num_compare = sz * sizeof(u32);
        
        if (std::memcmp(own_ptr, other_ptr, num_compare) != 0)
        {
            return false;
        }
    }
    
    return true;
}

//  ==: Check for equality.

bool util::categorical::operator ==(const util::categorical& other) const
{
    if (this == &other)
    {
        return true;
    }
    
    const u64 own_sz = size();
    const u64 other_sz = other.size();
    
    if (own_sz != other_sz)
    {
        return false;
    }
    
    if (m_progenitor_ids == other.m_progenitor_ids)
    {
        return unchecked_eq_progenitors_match(other, own_sz);
    }
    
    if (m_label_ids.size() != other.m_label_ids.size() || !categories_match(other))
    {
        return false;
    }
    
    std::unordered_map<u32, u32> visited_ids_a_to_b;
    
    for (const auto& category_it : m_category_indices)
    {
        const std::vector<u32>& col_a = m_labels[category_it.second];
        const std::vector<u32>& col_b = other.m_labels[other.m_category_indices.at(category_it.first)];
        
        for (u64 i = 0; i < own_sz; i++)
        {
            const u32 lab_a = col_a[i];
            u32 expect_lab_b;
            const auto visited_it = visited_ids_a_to_b.find(lab_a);
            
            //  We must get the corresponding label id for b.
            if (visited_it == visited_ids_a_to_b.end())
            {
                const std::string& label_a = m_label_ids.ref_at(lab_a);
                const auto& other_it = other.m_label_ids.find(label_a);
                
                if (other_it == other.m_label_ids.endk())
                {
                    //  a has a label that b doesn't have.
                    return false;
                }
                
                expect_lab_b = other_it->second;
                visited_ids_a_to_b.emplace(lab_a, expect_lab_b);
            }
            else
            {
                expect_lab_b = visited_it->second;
            }
            
            if (col_b[i] != expect_lab_b)
            {
                return false;
            }
        }
    }
    
    return true;
}

//  has_label: True if the label is present.

bool util::categorical::has_label(const std::string &label) const
{
    return m_in_category.find(label) != m_in_category.end();
}

//  has_label: True if the label id is present.

bool util::categorical::has_label(util::u32 label_id) const
{
    return m_label_ids.contains(label_id);
}

bool util::categorical::is_collapsed_expression_in_wrong_category(const std::string& category, const std::string& label) const
{
    return m_collapsed_expressions.count(label) > 0 && label != get_collapsed_expression(category);
}

//  has_category: True if the category is present.

bool util::categorical::has_category(const std::string &category) const
{
    return m_category_indices.find(category) != m_category_indices.end();
}

bool util::categorical::has_categories(const std::vector<std::string>& categories) const
{
    for (const auto& category : categories)
    {
        if (!has_category(category))
        {
            return false;
        }
    }
    
    return true;
}

//  resize: Resize such that each column of label indices has N rows.

void util::categorical::resize(util::u64 rows)
{
    for (auto& column : m_labels)
    {
        column.resize(rows, 0);
    }
}

//  reserve: Resize and add / remove labels as necessary.

void util::categorical::reserve(util::u64 rows)
{
    u64 orig_size = size();
    resize(rows);
    
    if (rows < orig_size)
    {
        prune();
    }
    else
    {
        set_all_collapsed_expressions(orig_size);
    }
}

//  repeat: Repeat contents of label ids array N times.
//
//      TODO: This can overflow.

void util::categorical::repeat(util::u64 times)
{
    const u64 sz = size();
    
    if (sz == 0 || times == 0)
    {
        return;
    }
    
    resize(sz + sz * times);
    const u64 lab_sz = m_labels.size();
    size_t n_copy = sz * sizeof(u32);
    
    for (u64 i = 0; i < lab_sz; i++)
    {
        u32* src = m_labels[i].data();
        u64 idx = sz;
        
        for (u64 j = 0; j < times; j++)
        {
            std::memcpy(src + idx, src, n_copy);
            idx += sz;
        }
    }
    
}

//  size: Get the current number of rows.

util::u64 util::categorical::size() const
{
    return m_labels.size() == 0 ? 0 : m_labels[0].size();
}

//  n_categories: Get the current number of categories.

util::u64 util::categorical::n_categories() const
{
    return m_category_indices.size();
}

//  n_labels: Get the current number of labels.

util::u64 util::categorical::n_labels() const
{
    return m_label_ids.size();
}

util::u32 util::categorical::get_label_id_or_0(const std::string& lab, bool* exist) const
{
    *exist = true;
    
    const auto lab_id_it = m_label_ids.find(lab);
    
    if (lab_id_it == m_label_ids.endk())
    {
        *exist = false;
        return 0;
    }
    
    return lab_id_it->second;
}

//  unchecked_get_label_column: Get a reference to the column of label_ids in which
//      a label resides. No checking is done to ensure that the label exists.

const std::vector<util::u32>& util::categorical::unchecked_get_label_column(const std::string& lab) const
{
    const std::string& in_cat = m_in_category.at(lab);
    const u64 cat_idx = m_category_indices.at(in_cat);
    return m_labels[cat_idx];
}

//  count: Get the number of rows associated with label.

util::u64 util::categorical::count(const std::string& lab) const
{
    bool exists;
    const u32 id = get_label_id_or_0(lab, &exists);
    
    if (!exists)
    {
        return 0;
    }
    
    u64 sum = 0;
    
    const std::vector<u32>& lab_col = unchecked_get_label_column(lab);
    const u64 sz = lab_col.size();
    
    for (u64 i = 0; i < sz; i++)
    {
        if (lab_col[i] == id)
        {
            sum++;
        }
    }
    
    return sum;
}

util::u64 util::categorical::count(const std::string& lab,
                                   const std::vector<util::u64>& indices,
                                   util::u32* status,
                                   util::u64 index_offset) const
{
    *status = util::categorical_status::OK;
    
    bool exists;
    const u32 id = get_label_id_or_0(lab, &exists);
    
    if (!exists)
    {
        return 0;
    }
    
    const std::vector<u32>& lab_col = unchecked_get_label_column(lab);
    const u64 n_indices = indices.size();
    const u64 sz = lab_col.size();
    
    u64 sum = 0;
    
    for (u64 i = 0; i < n_indices; i++)
    {
        const u64 idx = indices[i] - index_offset;
        
        if (idx >= sz)
        {
            *status = util::categorical_status::OUT_OF_BOUNDS;
            return 0;
        }
        
        if (lab_col[idx] == id)
        {
            sum++;
        }
    }
    
    return sum;
}

//  add_category: Add a new category.
//
//      An error code is returned if the category already exists,
//      or if the collapsed expression for the category is present
//      in another category.

util::u32 util::categorical::add_category(const std::string& category)
{
    std::string clpsed = get_collapsed_expression(category);
    
    if (has_label(clpsed) && m_in_category.at(clpsed) != category)
    {
        return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
    }
    
    if (has_category(category))
    {
        return categorical_status::CATEGORY_EXISTS;
    }
    
    unchecked_add_category(category, clpsed);
    
    return categorical_status::OK;
}

//  add_label: Add a label in a category.
//
//      An error code is returned if the label is already present
//      in another category.

util::u32 util::categorical::add_label(const std::string& category, const std::string& label)
{
    if (!has_category(category))
    {
        return util::categorical_status::CATEGORY_DOES_NOT_EXIST;
    }
    
    u32 ignore_id;
    return add_label_unchecked_has_category(category, label, &ignore_id);
}

//  add_label_unchecked_has_category: Add a label in a category, without checking whether the category exists.
//      If label does exist, confirms that it is in the correct category. Otherwise, also conditionally confirms
//      that it is not the collapsed expression for the wrong category.

util::u32 util::categorical::add_label_unchecked_has_category(const std::string& category,
                                                              const std::string& label,
                                                              u32* label_id)
{
    const auto& label_id_it = m_label_ids.find(label);
    
    if (label_id_it != m_label_ids.endk())
    {
        *label_id = label_id_it->second;
        //  Label either already exists or is in the wrong.
        return (category == m_in_category.at(label) ? categorical_status::OK : categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY);
    }
    
    //  Check if the label is a collapsed expression. If it is, ensure it is the collapsed
    //  expression for `category`.
    if (is_collapsed_expression_in_wrong_category(category, label))
    {
        return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
    }
    
    const u32 new_label_id = get_next_label_id();
    unchecked_insert_label(label, new_label_id, category);
    m_progenitor_ids.randomize();
    *label_id = new_label_id;
    
    return util::categorical_status::OK;
}

//  require_category: Add category if it does not exist.
//
//      If a current category contains the label that is the collapsed expression
//      of the incoming category, the operation will fail with a
//      status of `COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY`

util::u32 util::categorical::require_category(const std::string& category)
{
    std::string clpsed = get_collapsed_expression(category);
    
    if (has_label(clpsed) && m_in_category.at(clpsed) != category)
    {
        return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
    }
    
    if (!has_category(category))
    {
        unchecked_add_category(category, clpsed);
    }
    
    return util::categorical_status::OK;
}

//  unchecked_add_category [private]: Internally perform add category operation.

void util::categorical::unchecked_add_category(const std::string& category,
                                               const std::string& collapsed_expression)
{
    u64 sz = size();
    u64 ncats = n_categories();
    
    std::vector<u32> new_labs(sz);
    m_category_indices[category] = ncats;
    m_labels.push_back(new_labs);
    m_collapsed_expressions.insert(collapsed_expression);
    
    //  fill the category with the collapsed expression for the category.
    if (sz > 0)
    {
        set_collapsed_expressions(m_labels[m_labels.size()-1], category, collapsed_expression, 0);
    }
}

//  rename_category: Replace old category name with new category name.

util::u32 util::categorical::rename_category(const std::string &from, const std::string &to)
{
    if (!has_category(from))
    {
        return util::categorical_status::CATEGORY_DOES_NOT_EXIST;
    }
    
    if (has_category(to))
    {
        return (from == to ? categorical_status::OK : categorical_status::CATEGORY_EXISTS);
    }
    
    const std::string clpsed = get_collapsed_expression(to);
    
    if (has_label(clpsed) && m_in_category.at(clpsed) != from)
    {
        return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
    }
    
    std::vector<std::string> labs = in_category(from);
    
    for (const auto& lab : labs)
    {
        m_in_category[lab] = to;
    }
    
    util::u64 cat_idx = m_category_indices.at(from);
    m_category_indices.erase(from);
    m_category_indices[to] = cat_idx;
  
    m_collapsed_expressions.erase(get_collapsed_expression(from));
    m_collapsed_expressions.insert(clpsed);
    
    m_progenitor_ids.randomize();
    
    return util::categorical_status::OK;
}

//  unchecked_insert_label [private]: Internally add label and id to array.

void util::categorical::unchecked_insert_label(const std::string& lab,
                                               const util::u32 id,
                                               const std::string& category)
{
    m_label_ids.insert(lab, id);
    m_in_category[lab] = category;
}

//  set_collapsed_expressions: Initialize categories with collapsed expressions.

void util::categorical::set_collapsed_expressions(std::vector<util::u32> &labs,
                                                  const std::string& category,
                                                  const std::string& collapsed_expression,
                                                  util::u64 start_offset)
{
    util::u32 id;
    
    if (m_label_ids.contains(collapsed_expression))
    {
        id = m_label_ids.at(collapsed_expression);
    }
    else
    {
        id = get_next_label_id();
        unchecked_insert_label(collapsed_expression, id, category);
        m_progenitor_ids.randomize();
    }
    
    std::fill(labs.begin() + start_offset, labs.end(), id);
}

//  set_all_collapsed_expressions: Initialize all categories with collapsed expressions.

void util::categorical::set_all_collapsed_expressions(util::u64 start_offset)
{
    for (const auto& it : m_category_indices)
    {
        const std::string& cat = it.first;
        const util::u64 cat_idx = it.second;
        
        std::vector<util::u32>& labs = m_labels[cat_idx];
        
        set_collapsed_expressions(labs, cat, get_collapsed_expression(cat), start_offset);
    }
}

//  find: Get indices of label combinations.

std::vector<util::u64> util::categorical::find(const std::vector<std::string>& labels,
                                               util::u64 index_offset) const
{
    std::vector<util::u64> dummy_indices;
    util::u32 dummy_status;
    const bool use_indices = false;
    const bool flip_index = false;
    
    return find_impl(labels, use_indices, flip_index, dummy_indices, &dummy_status, index_offset);
}

//  find: Get indices of label combinations, from subsets of rows.

std::vector<util::u64> util::categorical::find(const std::vector<std::string>& labels,
                                               const std::vector<util::u64>& indices,
                                               util::u32* status,
                                               util::u64 index_offset) const
{
    const bool use_indices = true;
    const bool flip_index = false;
    
    return find_impl(labels, use_indices, flip_index, indices, status, index_offset);
}

//  find_not: Get indices of rows, except those associated with label combination.

std::vector<util::u64> util::categorical::find_not(const std::vector<std::string>& labels,
                                                   util::u64 index_offset) const
{
    std::vector<util::u64> dummy_indices;
    util::u32 dummy_status;
    const bool use_indices = false;
    const bool flip_index = true;
    
    return find_impl(labels, use_indices, flip_index, dummy_indices, &dummy_status, index_offset);
}

//  find_not: Get indices of rows, except those associated with label combination, in
//      subset of rows.

std::vector<util::u64> util::categorical::find_not(const std::vector<std::string>& labels,
                                                   const std::vector<util::u64>& indices,
                                                   util::u32* status,
                                                   util::u64 index_offset) const
{
    const bool use_indices = true;
    const bool flip_index = true;
    
    return find_impl(labels, use_indices, flip_index, indices, status, index_offset);
}

//  find_or: Get indices of any among labels.

std::vector<util::u64> util::categorical::find_or(const std::vector<std::string>& labels,
                                                  util::u64 index_offset) const
{
    std::vector<util::u64> dummy_indices;
    util::u32 dummy_status;
    const bool use_indices = false;
    const bool flip_index = false;
    
    return find_or_impl(labels, use_indices, flip_index, dummy_indices, &dummy_status, index_offset);
}

//  find_or: Get indices of any among labels, from subsets of rows.

std::vector<util::u64> util::categorical::find_or(const std::vector<std::string>& labels,
                                                  const std::vector<util::u64>& indices,
                                                  util::u32* status,
                                                  util::u64 index_offset) const
{
    const bool use_indices = true;
    const bool flip_index = false;
    
    return find_or_impl(labels, use_indices, flip_index, indices, status, index_offset);
}

std::vector<util::u64> util::categorical::find_none(const std::vector<std::string>& labels,
                                                    util::u64 index_offset) const
{
    std::vector<util::u64> dummy_indices;
    util::u32 dummy_status;
    const bool use_indices = false;
    const bool flip_index = true;
    
    return find_or_impl(labels, use_indices, flip_index, dummy_indices, &dummy_status, index_offset);
}

//  find_or: Get indices of any among labels, from subsets of rows.

std::vector<util::u64> util::categorical::find_none(const std::vector<std::string>& labels,
                                                    const std::vector<util::u64>& indices,
                                                    util::u32* status,
                                                    util::u64 index_offset) const
{
    const bool use_indices = true;
    const bool flip_index = true;
    
    return find_or_impl(labels, use_indices, flip_index, indices, status, index_offset);
}

util::u32 util::categorical::find_flipped_apply_mask(util::bit_array& final_index,
                                                     const util::u64 sz,
                                                     const std::vector<util::u64>& indices,
                                                     const util::u64 index_offset)
{
    util::bit_array mask(sz, false);
    
    util::u32 assign_status = util::categorical::assign_bit_array(mask, indices, index_offset);
    
    if (assign_status != util::categorical_status::OK)
    {
        return assign_status;
    }
  
    if (sz > 0)
    {
        bit_array::unchecked_dot_and(final_index, final_index, mask, 0, sz);
    }
    
    return util::categorical_status::OK;
}

std::vector<util::u64> util::categorical::find_flipped_get_complete_index(const bool use_indices,
                                                                          const util::u64 sz,
                                                                          const std::vector<util::u64>& indices,
                                                                          const util::u64 index_offset,
                                                                          util::u32* status)
{
    util::bit_array final_index(sz, true);
    std::vector<util::u64> empty_result;
    
    if (use_indices)
    {
        u32 tmp_status = categorical::find_flipped_apply_mask(final_index, sz, indices, index_offset);
        
        if (tmp_status != util::categorical_status::OK)
        {
            *status = tmp_status;
            return empty_result;
        }
    }
    
    return util::bit_array::findv(final_index, index_offset);
}

//  find_impl [private]: Private implementation of find, with and without subsets

std::vector<util::u64> util::categorical::find_impl(const std::vector<std::string>& labels,
                                                    const bool use_indices,
                                                    const bool flip_index,
                                                    const std::vector<util::u64>& indices,
                                                    util::u32* status,
                                                    util::u64 index_offset) const
{
    std::vector<util::u64> out;
    
    const u64 n_in = labels.size();
    const u64 sz = size();
    
    *status = util::categorical_status::OK;
    
    if (n_in == 0)
    {
        if (sz == 0 || !flip_index)
        {
            return out;
        }
        else
        {
            //  return complete / masked indices into `this`
            return find_flipped_get_complete_index(use_indices, sz, indices, index_offset, status);
        }
    }
    
    std::unordered_map<std::string, bit_array> index_map;
    
    for (u64 i = 0; i < n_in; i++)
    {
        const std::string& lab = labels[i];
        
        auto search_it = m_label_ids.find(lab);
        
        //  label doesn't exist
        if (search_it == m_label_ids.endk())
        {
            if (flip_index)
            {
                return find_flipped_get_complete_index(use_indices, sz, indices, index_offset, status);
            }
            else
            {
                return out;
            }
        }
        
        const u32 lab_id = search_it->second;
        const std::string& cat = m_in_category.at(lab);
        const u64 cat_idx = m_category_indices.at(cat);
        
        bit_array index;
        
        if (use_indices)
        {
            index = util::categorical::assign_bit_array(m_labels[cat_idx], lab_id, indices, status, index_offset);
            if (*status != util::categorical_status::OK)
            {
                return out;
            }
        }
        else
        {
            index = util::categorical::assign_bit_array(m_labels[cat_idx], lab_id);
        }
        
        if (index_map.find(cat) == index_map.end())
        {
            index_map[cat] = index;
        }
        else if (sz > 0)
        {
            bit_array& current = index_map[cat];
            bit_array::unchecked_dot_or(current, current, index, 0, sz);
        }
    }
    
    util::bit_array final_index(sz, true);
  
    if (sz > 0)
    {
        for (const auto& it : index_map)
        {
            bit_array::unchecked_dot_and(final_index, final_index, it.second, 0, sz);
        }
      
        if (flip_index)
        {
            final_index.flip();
          
            if (use_indices)
            {
                u32 tmp_status = categorical::find_flipped_apply_mask(final_index, sz, indices, index_offset);
              
                if (tmp_status != util::categorical_status::OK)
                {
                    *status = tmp_status;
                    return out;
                }
            }
        }
    }
    
    return bit_array::findv(final_index, index_offset);
}

//  find_or_impl [private]: Private implementation of find_or, with and without subsets

std::vector<util::u64> util::categorical::find_or_impl(const std::vector<std::string>& labels,
                                                       const bool use_indices,
                                                       const bool flip_index,
                                                       const std::vector<util::u64>& indices,
                                                       util::u32* status,
                                                       util::u64 index_offset) const
{
    using util::u64;
    using util::bit_array;
    
    std::vector<util::u64> out;
    
    const u64 n_in = labels.size();
    const u64 sz = size();
    
    *status = util::categorical_status::OK;
    
    if (n_in == 0)
    {
        if (sz == 0 || !flip_index)
        {
            return out;
        }
        else
        {
            //  return complete / masked indices into `this`
            return find_flipped_get_complete_index(use_indices, sz, indices, index_offset, status);
        }
    }
    
    auto label_it_end = m_label_ids.endk();
    
    util::bit_array final_index(sz, false);
    
    for (u64 i = 0; i < n_in; i++)
    {
        const std::string& lab = labels[i];
        const auto search_it = m_label_ids.find(lab);
        
        //  label doesn't exist
        if (search_it == label_it_end)
        {
            continue;
        }
        
        const u32 lab_id = search_it->second;
        const std::string& cat = m_in_category.at(lab);
        const u64 cat_idx = m_category_indices.at(cat);
        
        bit_array index;
        
        if (use_indices)
        {
            index = util::categorical::assign_bit_array(m_labels[cat_idx], lab_id, indices, status, index_offset);
            if (*status != util::categorical_status::OK)
            {
                return out;
            }
        }
        else
        {
            index = util::categorical::assign_bit_array(m_labels[cat_idx], lab_id);
        }
      
        if (sz > 0)
        {
            bit_array::unchecked_dot_or(final_index, final_index, index, 0, sz);
        }
    }
    
    if (flip_index)
    {
        final_index.flip();
        
        if (use_indices)
        {
            u32 tmp_status = categorical::find_flipped_apply_mask(final_index, sz, indices, index_offset);
            
            if (tmp_status != util::categorical_status::OK)
            {
                *status = tmp_status;
                return out;
            }
        }
    }
    
    return bit_array::findv(final_index, index_offset);
}

util::u32 util::categorical::assign_bit_array(util::bit_array& mask,
                                              const std::vector<util::u64>& at_indices,
                                              util::u64 index_offset)
{
    const u64 mask_sz = mask.size();
    const u64 n_indices = at_indices.size();
    const u64* indices = at_indices.data();
    
    for (u64 i = 0; i < n_indices; i++)
    {
        u64 assign_idx = indices[i] - index_offset;
        
        if (assign_idx >= mask_sz)
        {
            return util::categorical_status::OUT_OF_BOUNDS;
        }
        
        mask.unchecked_place(true, assign_idx);
    }
    
    return util::categorical_status::OK;
}

//  assign_bit_array: Assign true to bit_array where label id is found

util::bit_array util::categorical::assign_bit_array(const std::vector<util::u32>& labels, util::u32 lab)
{
    u64 sz = labels.size();
    
    util::bit_array out(sz, false);
    
    for (util::u64 i = 0; i < sz; i++)
    {
        if (labels[i] == lab)
        {
            out.unchecked_place(true, i);
        }
    }
    
    return out;
}

util::bit_array util::categorical::assign_bit_array(const std::vector<util::u32>& labels,
                                                    util::u32 lab,
                                                    const std::vector<util::u64>& indices,
                                                    util::u32* status,
                                                    util::u64 index_offset)
{
    *status = util::categorical_status::OK;
    
    util::u64 sz = labels.size();
    util::bit_array out(sz, false);
    util::u64 n_inds = indices.size();
    
    for (util::u64 i = 0; i < n_inds; i++)
    {
        const util::u64 idx = indices[i] - index_offset;
        
        if (idx >= sz)
        {
            *status = util::categorical_status::OUT_OF_BOUNDS;
            return out;
        }
        
        if (labels[idx] == lab)
        {
            out.unchecked_place(true, idx);
        }
    }
    
    return out;
}

std::vector<util::u64> util::categorical::get_category_indices(const std::vector<std::string>& cats,
                                                               const util::u64 n_cats,
                                                               bool* exist) const
{
    std::vector<u64> category_inds;
    *exist = true;
    
    for (u64 i = 0; i < n_cats; i++)
    {
        auto category_idx_it = m_category_indices.find(cats[i]);
        
        //  if a category doesn't exist, no combinations can exist with it.
        if (category_idx_it == m_category_indices.end())
        {
            *exist = false;
            return std::vector<u64>();
        }
        
        category_inds.push_back(category_idx_it->second);
    }
    
    return category_inds;
}

std::vector<util::u64> util::categorical::get_category_indices_unchecked_has_category(const std::vector<std::string>& cats) const
{
    const u64 num_cats = cats.size();
    std::vector<util::u64> result(num_cats);
    
    for (u64 i = 0; i < num_cats; i++)
    {
        result[i] = m_category_indices.at(cats[i]);
    }
    
    return result;
}

//  find_all_hash_impl: Get indices of all possible unique combinations of labels, hashing rows.

std::vector<std::vector<util::u64>>
util::categorical::find_all_hash_impl(const std::vector<std::string>& categories,
                                      const bool use_indices,
                                      const std::vector<util::u64>& indices,
                                      util::u32* status,
                                      util::u64 index_offset) const
{
    *status = util::categorical_status::OK;
    std::vector<std::vector<u64>> result;
    
    u64 n_cats_in = categories.size();
    bool cats_exist;
    std::vector<u64> category_inds = get_category_indices(categories, n_cats_in, &cats_exist);
    
    if (n_cats_in == 0 || !cats_exist)
    {
        return result;
    }
    
    const u64 rows = use_indices ? indices.size() : size();
    const u64 max_rows = use_indices ? size() : rows;
    
    std::string hash_code = make_label_id_hash_string(n_cats_in);
    char* hash_code_ptr = &hash_code[0];
    
    std::unordered_map<std::string, u64> combination_exists;
    u64 next_id = 0;
    
    for (u64 i = 0; i < rows; i++)
    {
        u64 internal_index;
        u64 input_index;
        
        if (use_indices)
        {
            input_index = indices[i];
            internal_index = input_index - index_offset;
            
            if (internal_index >= max_rows)
            {
                *status = util::categorical_status::OUT_OF_BOUNDS;
                return result;
            }
        }
        else
        {
            internal_index = i;
            input_index = i + index_offset;
        }
        
        build_row_hash(hash_code_ptr, m_labels, internal_index, category_inds);
        
        const auto c_it = combination_exists.find(hash_code);
        u64 comb_idx;
        
        //  Doesn't exist, add a new set of indices.
        if (c_it == combination_exists.end())
        {
            combination_exists[hash_code] = next_id;
            comb_idx = next_id;
            next_id++;
            result.push_back(std::vector<u64>());
        }
        //  Does exist, get the index into `result`.
        else
        {
            comb_idx = c_it->second;
        }
        
        std::vector<u64>& inds_ptr = result[comb_idx];
        inds_ptr.push_back(input_index);
    }
    
    return result;
}
    
std::vector<std::vector<util::u64>>
util::categorical::find_all_custom_hash_impl(const std::vector<std::string>& categories,
                                             const bool use_indices,
                                             const std::vector<util::u64>& indices,
                                             util::u32* status,
                                             util::u64 index_offset) const
{
    struct HashUnsignedInt {
        //  https://www.partow.net/programming/hashfunctions/
        //  SDBM Hash Function
        const u32 operator()(const u32* row, const std::size_t num_columns) const
        {
            u32 hash = 0;
            
            for (std::size_t i = 0; i < num_columns; i++)
            {
                hash = row[i] + (hash << 6) + (hash << 16) - hash;
            }
            
            return hash;
        }
    };
    
    *status = util::categorical_status::OK;
    std::vector<std::vector<u64>> result;
    
    const u64 num_cats = categories.size();
    bool cats_exist;
    std::vector<u64> category_inds = get_category_indices(categories, num_cats, &cats_exist);
    
    if (num_cats == 0 || !cats_exist)
    {
        return result;
    }
    
    const u64 rows = use_indices ? indices.size() : size();
    const u64 max_rows = use_indices ? size() : rows;
    
    std::vector<u32> ids(num_cats);
    u32* id_data = &ids[0];
    u64 next_id = 0;
    
    u64 row_map_size = 2 * u64(std::sqrt(double(rows)));
    if (row_map_size < 10)
    {
        row_map_size = 10;
    }
    
    util::IntegralTypeRowMap<u32, u64, HashUnsignedInt> row_map(row_map_size, num_cats);
    
    for (u64 i = 0; i < rows; i++)
    {
        u64 internal_index;
        u64 input_index;
        
        if (use_indices)
        {
            input_index = indices[i];
            internal_index = input_index - index_offset;
            
            if (internal_index >= max_rows)
            {
                *status = util::categorical_status::OUT_OF_BOUNDS;
                return result;
            }
        }
        else
        {
            internal_index = i;
            input_index = i + index_offset;
        }
        
        for (u64 j = 0; j < num_cats; j++)
        {
            id_data[j] = m_labels[category_inds[j]][internal_index];
        }
        
        const auto c_it = row_map.find(id_data);
        u64 comb_idx;

        //  Doesn't exist, add a new set of indices.
        if (c_it.value == nullptr)
        {
            row_map.insert(c_it, id_data, next_id);
            comb_idx = next_id++;
            result.emplace_back();
        }
        //  Does exist, get the index into `result`.
        else
        {
            comb_idx = *c_it.value;
        }

        std::vector<u64>& inds_ptr = result[comb_idx];
        inds_ptr.push_back(input_index);
    }
    
    return result;
}

//  find_all_sort_impl: Get indices of all possible unique combinations of labels, sorting rows.

std::vector<std::vector<util::u64>>
util::categorical::find_all_sort_impl(const std::vector<std::string>& categories,
                                      const bool use_indices,
                                      const std::vector<util::u64>& indices,
                                      util::u32* status,
                                      util::u64 index_offset) const
{
    *status = util::categorical_status::OK;
    
    const u64 rows = use_indices ? indices.size() : size();
    //  @Robustness: Restrict num categories to s64 range.
    const u64 num_cats_in = categories.size();
    bool cats_exist;
    const std::vector<u64> category_inds = get_category_indices(categories, num_cats_in, &cats_exist);
    
    if (num_cats_in == 0 || !cats_exist || rows == 0)
    {
        return {};
    }
    
    if (use_indices)
    {
        const u32 bounds_status = bounds_check(indices.data(), indices.size(), size(), index_offset);
        if (bounds_status != categorical_status::OK)
        {
            *status = bounds_status;
            return {};
        }
    }
    
    std::vector<u64> sorted_indices(rows);
    std::iota(sorted_indices.begin(), sorted_indices.end(), 0);
    
    if (num_cats_in > 1)
    {
        //  Sort rows of matrix.
        std::vector<u64> row_indices(rows);
        std::vector<u64> sorted_indices_tmp(rows);
        
        for (s64 i = num_cats_in-1; i >= 0; i--)
        {
            std::iota(row_indices.begin(), row_indices.end(), 0);
            const std::vector<u32>& column = m_labels[category_inds[i]];
            
            if (use_indices)
            {
                std::stable_sort(row_indices.begin(), row_indices.end(), [&column, &sorted_indices, &indices, index_offset](u64 i0, u64 i1) -> bool
                {
                    const u64 col_i0 = indices[sorted_indices[i0]] - index_offset;
                    const u64 col_i1 = indices[sorted_indices[i1]] - index_offset;
                    
                    return column[col_i0] < column[col_i1];
                });
            }
            else
            {
                std::stable_sort(row_indices.begin(), row_indices.end(), [&column, &sorted_indices](u64 i0, u64 i1) -> bool
                {
                    return column[sorted_indices[i0]] < column[sorted_indices[i1]];
                });
            }
            
            for (u64 j = 0; j < rows; j++)
            {
                sorted_indices_tmp[j] = sorted_indices[row_indices[j]];
            }
            
            std::swap(sorted_indices_tmp, sorted_indices);
        }
    }
    else
    {
        //  Just sort the column.
        const std::vector<u32>& column = m_labels[category_inds[0]];
        
        if (use_indices)
        {
            std::sort(sorted_indices.begin(), sorted_indices.end(), [&column, &indices, index_offset](u64 i0, u64 i1) -> bool
            {
                return column[indices[i0] - index_offset] < column[indices[i1] - index_offset];
            });
        }
        else
        {
            std::sort(sorted_indices.begin(), sorted_indices.end(), [&column](u64 i0, u64 i1) -> bool
            {
                return column[i0] < column[i1];
            });
        }
    }
    
    std::vector<std::vector<u64>> result;
    u64 reference = 0;
    
    for (u64 i = 0; i < rows; i++)
    {
        bool new_combination = i == reference || false;
        u64 ref_row;
        u64 test_row;
        
        if (use_indices)
        {
            ref_row = indices[sorted_indices[reference]] - index_offset;
            test_row = indices[sorted_indices[i]] - index_offset;
        }
        else
        {
            ref_row = sorted_indices[reference];
            test_row = sorted_indices[i];
        }
        
        for (u64 j = 0; j < num_cats_in; j++)
        {
            const u64 col = category_inds[j];
            const u32 ref_id = m_labels[col][ref_row];
            const u32 test_id = m_labels[col][test_row];
            
            if (ref_id != test_id)
            {
                new_combination = true;
                break;
            }
        }
        
        if (new_combination)
        {
            reference = i;
            result.push_back(std::vector<u64>());
        }
        
        std::vector<u64>& end = result[result.size()-1];
        end.push_back(test_row + index_offset);
    }
    
    return result;
}

std::vector<std::vector<util::u64>> util::categorical::find_all_method_dispatch(const util::categorical::find_all_method method,
                                                                                const std::vector<std::string>& categories,
                                                                                const bool use_indices,
                                                                                const std::vector<util::u64>& indices,
                                                                                util::u32* status,
                                                                                util::u64 index_offset) const
{
    switch (method)
    {
        case find_all_method::hash:
            return find_all_hash_impl(categories, use_indices, indices, status, index_offset);
        case find_all_method::sort:
            return find_all_sort_impl(categories, use_indices, indices, status, index_offset);
        case find_all_method::custom_hash:
            return find_all_custom_hash_impl(categories, use_indices, indices, status, index_offset);
        default:
            return find_all_hash_impl(categories, use_indices, indices, status, index_offset);
    }
}

std::vector<std::vector<util::u64>> util::categorical::find_all(util::categorical::find_all_method method,
                                                                const std::vector<std::string>& categories,
                                                                util::u64 index_offset) const
{
    u32 ignore_status;
    return find_all_method_dispatch(method, categories, false, {}, &ignore_status, index_offset);
}

//  find_all: Specify underlying implementation method, with indices.

std::vector<std::vector<util::u64>> util::categorical::find_all(util::categorical::find_all_method method,
                                                                const std::vector<std::string>& categories,
                                                                const std::vector<util::u64>& indices,
                                                                util::u32* status,
                                                                util::u64 index_offset) const
{
    return find_all_method_dispatch(method, categories, true, indices, status, index_offset);
}

//  find_all: Get indices of all possible unique combinations of labels.

std::vector<std::vector<util::u64>> util::categorical::find_all(const std::vector<std::string>& categories,
                                                                util::u64 index_offset) const
{
    u32 ignore_status;
    return find_all_hash_impl(categories, false, {}, &ignore_status, index_offset);
}

//  find_all: Get indices of all possible unique combinations of labels, from subset,
//      with bounds check.
//
//      find_all does not return the combinations.

std::vector<std::vector<util::u64>> util::categorical::find_all(const std::vector<std::string>& categories,
                                                                const std::vector<util::u64>& indices,
                                                                util::u32* status,
                                                                util::u64 index_offset) const
{
    return find_all_hash_impl(categories, true, indices, status, index_offset);
}

//  find_allc: Get indices of all possible unique combinations of labels.
//
//      find_allc also returns the combinations.

util::combinations_t util::categorical::find_allc(const std::vector<std::string>& categories,
                                                  util::u64 index_offset) const
{
    util::u32 dummy_status;
    std::vector<util::u64> dummy_indices;
    return find_allc_impl(categories, false, dummy_indices, &dummy_status, index_offset);
}

//  find_allc: Get indices of all possible unique combinations of labels, from subset.
//
//      find_allc also returns the combinations.

util::combinations_t util::categorical::find_allc(const std::vector<std::string>& categories,
                                                  const std::vector<util::u64>& indices,
                                                  util::u32* status,
                                                  util::u64 index_offset) const
{
    return find_allc_impl(categories, true, indices, status, index_offset);
}

//  find_allc_impl [private]: Implementation of find_allc and findall_c [indexed]

util::combinations_t util::categorical::find_allc_impl(const std::vector<std::string>& categories,
                                                       const bool use_indices,
                                                       const std::vector<util::u64>& indices,
                                                       util::u32* status,
                                                       util::u64 index_offset) const
{
    util::combinations_t result;
    *status = util::categorical_status::OK;
    
    u64 n_cats_in = categories.size();
    bool cats_exist;
    std::vector<u64> category_inds = get_category_indices(categories, n_cats_in, &cats_exist);
    
    if (n_cats_in == 0 || !cats_exist)
    {
        return result;
    }
    
    std::string hash_code = make_label_id_hash_string(n_cats_in);
    char* hash_code_ptr = &hash_code[0];
    
    const u64 sz = size();
    const u64 rows = use_indices ? indices.size() : sz;
    
    std::unordered_map<std::string, u64> combination_exists;
    u64 next_id = 0;
    
    for (u64 i = 0; i < rows; i++)
    {
        u64 input_idx = i + index_offset;
        u64 internal_idx = i;
        
        if (use_indices)
        {
            input_idx = indices[i];
            internal_idx = input_idx - index_offset;
            
            if (internal_idx >= sz)
            {
                *status = util::categorical_status::OUT_OF_BOUNDS;
                return result;
            }
        }
        
        build_row_hash(hash_code_ptr, m_labels, internal_idx, category_inds);
        
        auto c_it = combination_exists.find(hash_code);
        const bool c_exists = c_it != combination_exists.end();
        u64 comb_idx;
        
        if (!c_exists)
        {
            for (u64 j = 0; j < n_cats_in; j++)
            {
                const std::vector<u32>& full_cat = m_labels[category_inds[j]];
                result.combinations.push_back(m_label_ids.ref_at(full_cat[internal_idx]));
            }
            
            combination_exists[hash_code] = next_id;
            comb_idx = next_id;
            next_id++;
            result.indices.push_back(std::vector<u64>());
        }
        else
        {
            comb_idx = c_it->second;
        }
        
        std::vector<u64>& inds_ptr = result.indices[comb_idx];
        inds_ptr.push_back(input_idx);
    }
    
    return result;
}

//  keep_each: Retain one row for each combination of labels.
//
//      keep_each returns the indices used to generate each row of
//      the modified object

std::vector<std::vector<util::u64>> util::categorical::keep_each(const std::vector<std::string> &categories,
                                                                 util::u64 index_offset)
{
    std::vector<std::vector<util::u64>> indices = find_all(categories, index_offset);
    
    unchecked_keep_each(indices, index_offset);
    
    return indices;
}

//  keep_each: Retain one row for each combination of labels, from subset.
//
//      keep_each returns the indices used to generate each row of
//      the modified object

std::vector<std::vector<util::u64>> util::categorical::keep_each(const std::vector<std::string>& categories,
                                                                 const std::vector<util::u64>& indices,
                                                                 util::u32* status,
                                                                 util::u64 index_offset)
{
    std::vector<std::vector<util::u64>> out_indices = find_all(categories, indices, status, index_offset);
    
    if (*status != util::categorical_status::OK)
    {
        return out_indices;
    }
    
    unchecked_keep_each(out_indices, index_offset);
    
    return out_indices;
}

//  keep_eachc: Retain one row for each combination of labels.
//
//      keep_eachc also returns the label combinations associated with
//      each row.

util::combinations_t util::categorical::keep_eachc(const std::vector<std::string> &categories,
                                                  util::u64 index_offset)
{
    util::combinations_t combs = find_allc(categories, index_offset);
    
    unchecked_keep_each(combs.indices, index_offset);
    
    return combs;
}

//  keep_eachc: Retain one row for each combination of labels, from subset.
//
//      keep_eachc also returns the label combinations associated with
//      each row.

util::combinations_t util::categorical::keep_eachc(const std::vector<std::string> &categories,
                                                   const std::vector<util::u64>& indices,
                                                   util::u32* status,
                                                   util::u64 index_offset)
{
    util::combinations_t combs = find_allc(categories, indices, status, index_offset);
    
    if (*status != util::categorical_status::OK)
    {
        return combs;
    }
    
    unchecked_keep_each(combs.indices, index_offset);
    
    return combs;
}

//  unchecked_keep_each [private]: Main utility to keep each subset.

void util::categorical::unchecked_keep_each(const std::vector<std::vector<util::u64>>& indices,
                                            util::u64 index_offset)
{
    using util::u64;
    using util::u32;
    
    util::categorical copy = util::categorical::empty_copy(*this);
    
    const u64 n_indices = indices.size();
    const u64 n_cats = m_labels.size();
    
    copy.resize(n_indices);
    
    bool randomize_on_insert = true;
    
    for (u64 i = 0; i < n_cats; i++)
    {
        const std::vector<u32>& labs = m_labels[i];
        std::vector<u32>& copy_labs = copy.m_labels[i];
        
        for (u64 j = 0; j < n_indices; j++)
        {
            const std::vector<u64>& c_indices = indices[j];
            u64 n_c_indices = c_indices.size();
            
            u32 first_lab = labs[c_indices[0] - index_offset];
            
            bool should_proceed = true;
            bool need_collapse = false;
            u64 k = 1;
            
            while (should_proceed && k < n_c_indices)
            {
                u32 c_lab = labs[c_indices[k] - index_offset];
                
                if (c_lab != first_lab)
                {
                    should_proceed = false;
                    need_collapse = true;
                }
                
                k++;
            }
            
            if (need_collapse)
            {
                const std::string& str_lab = m_label_ids.at(first_lab);
                const std::string& cat = m_in_category.at(str_lab);
                
                std::string collapsed_expression = get_collapsed_expression(cat);
                
                u32 collapsed_id;
                
                if (copy.m_label_ids.contains(collapsed_expression))
                {
                    collapsed_id = copy.m_label_ids.at(collapsed_expression);
                }
                else
                {
                    collapsed_id = copy.get_next_label_id();
                    copy.unchecked_insert_label(collapsed_expression, collapsed_id, cat);
                    
                    if (randomize_on_insert)
                    {
                        m_progenitor_ids.randomize();
                        copy.m_progenitor_ids.randomize();
                        randomize_on_insert = false;
                    }
                }
                
                copy_labs[j] = collapsed_id;
            }
            else
            {
                copy_labs[j] = first_lab;
            }
        }
    }
    
    copy.prune();
    
    *this = std::move(copy);
}

//  one: Retain a single row, collapsing non-uniform categories.

void util::categorical::one()
{
    for (const auto& it : m_category_indices)
    {
        const std::vector<u32>& ids = m_labels[it.second];
        
        if (!is_uniform(ids))
        {
            collapse_category(it.first);
        }
    }
    
    if (size() <= 1)
    {
        return;
    }
    
    resize(1);
}

//  set_category: Set partial contents of a category.

util::u32 util::categorical::set_category(const std::string& category,
                                          const std::vector<std::string>& full_category,
                                          const std::vector<util::u64>& at_indices,
                                          util::u64 index_offset)
{
    auto category_it = m_category_indices.find(category);
    
    if (category_it == m_category_indices.end())
    {
        return util::categorical_status::CATEGORY_DOES_NOT_EXIST;
    }
    
    const u64 sz = size();
    const u64 cat_sz = full_category.size();
    const u64 n_indices = at_indices.size();
    
    bool is_scalar = false;
    
    if (n_indices != cat_sz)
    {
        if (cat_sz == 1 && n_indices > 0)
        {
            is_scalar = true;
        }
        else if (n_indices == 0)
        {
            return util::categorical_status::OK;
        }
        else
        {
            return util::categorical_status::WRONG_INDEX_SIZE;
        }
    }
    
    if (sz == 0)
    {
#ifdef CAT_ALLOW_SET_FROM_SIZE0
        if (n_indices == 0)
        {
            return util::categorical_status::OK;
        }
        
        //  Already confirmed that n_indices is > 0.
        const u64 max = *std::max_element(at_indices.begin(), at_indices.end());
        
        if (max - index_offset > max || max == ~(u64(0)))
        {
            return util::categorical_status::CAT_OVERFLOW;
        }
        
        reserve(max - index_offset + 1);
#else
        return util::categorical_status::WRONG_CATEGORY_SIZE;
#endif
    }
    else
    {
        u32 bounds_status = bounds_check(at_indices.data(), n_indices, sz, index_offset);
        
        if (bounds_status != util::categorical_status::OK)
        {
            return bounds_status;
        }
    }
    
    const u64 category_idx = category_it->second;
    std::vector<u32>& labels = m_labels[category_idx];
    
    std::unordered_map<std::string, u32> processed;
    
    for (u64 i = 0; i < n_indices; i++)
    {
        const std::string& lab = is_scalar ? full_category[0] : full_category[i];
        u32 lab_id;
        
        if (processed.count(lab) == 0)
        {
            const u32 add_status = add_label_unchecked_has_category(category, lab, &lab_id);
            if (add_status != categorical_status::OK)
            {
                if (sz == 0)
                {
                    reserve(0);
                }
                
                return add_status;
            }
      
            processed[lab] = lab_id;
        }
        else
        {
            lab_id = processed[lab];
        }
        
        labels[at_indices[i] - index_offset] = lab_id;
    }
    
#ifdef CAT_PRUNE_AFTER_ASSIGN
    prune();
#endif
    
    return util::categorical_status::OK;
    
}

//  set_category: Set full contents of a category.
//
//      If the object is of size 0, the incoming category can be of any size.
//
//      Else, if the incoming category is a vector of size 1 (i.e., a "scalar"),
//      the full contents of the category are set to the label at category[0].
//
//      Otherwise, the full category must match the size of the categorical object.

util::u32 util::categorical::set_category(const std::string& category,
                                          const std::vector<std::string>& full_category)
{
    const u64 own_size = size();
    const u64 cat_sz = full_category.size();
    
    if (cat_sz == 1 && own_size > 0)
    {
        return fill_category(category, full_category[0]);
    }
    
    const auto category_it = m_category_indices.find(category);
    if (category_it == m_category_indices.end())
    {
        return util::categorical_status::CATEGORY_DOES_NOT_EXIST;
    }
    
    const u64 category_idx = category_it->second;
    
    if (own_size > 0 && cat_sz != own_size)
    {
        return util::categorical_status::WRONG_CATEGORY_SIZE;
    }
    
    if (own_size == 0)
    {
#ifdef CAT_ALLOW_SET_FROM_SIZE0
        reserve(cat_sz);
#else
        return util::categorical_status::WRONG_INDEX_SIZE;
#endif
    }
    
    std::vector<u32>& labels = m_labels[category_idx];
    std::unordered_map<std::string, u32> processed;
    auto copy_ids = m_label_ids;
    
    for (u64 i = 0; i < cat_sz; i++)
    {
        const std::string& lab = full_category[i];
        u32 lab_id;
        const auto processed_it = processed.find(lab);
        
        if (processed_it == processed.end())
        {
            const bool had_label = has_label(lab);
            const u32 add_status = add_label_unchecked_has_category(category, lab, &lab_id);
            if (add_status != util::categorical_status::OK)
            {
                if (own_size == 0)
                {
                    reserve(0);
                }
                
                return add_status;
            }
            
            if (had_label)
            {
                copy_ids.erase(lab);
            }

            processed[lab] = lab_id;
        }
        else
        {
            lab_id = processed_it->second;
        }
        
        labels[i] = lab_id;
    }
    
    const std::vector<std::string> to_erase = copy_ids.keys();
    
    for (const auto& key : to_erase)
    {
        if (m_in_category.at(key) == category)
        {
            m_label_ids.erase(key);
            m_in_category.erase(key);
        }
    }
    
    return util::categorical_status::OK;
}

//  fill_category: Fill category with single label.

util::u32 util::categorical::fill_category(const std::string& category, const std::string& lab)
{
    const auto category_it = m_category_indices.find(category);
    
    if (category_it == m_category_indices.end())
    {
        return util::categorical_status::CATEGORY_DOES_NOT_EXIST;
    }
    
    const u64 sz = size();
    
    //  filling category when size is 0 has no effect.
    if (sz == 0)
    {
        return util::categorical_status::OK;
    }
    
    if (is_collapsed_expression_in_wrong_category(category, lab))
    {
        return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
    }
    
    auto lab_it = m_label_ids.find(lab);
    bool exists = lab_it != m_label_ids.endk();
    
    u32 lab_id;
    
    if (exists)
    {
        if (m_in_category.at(lab) != category)
        {
            return util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY;
        }
        
        lab_id = lab_it->second;
    }
    else
    {
        lab_id = get_next_label_id();
    }
    
    //  erase all other labels in category
    std::vector<std::string> in_cat = in_category(category);
    u64 n_in_cat = in_cat.size();
    
    for (u64 i = 0; i < n_in_cat; i++)
    {
        const std::string& c_lab = in_cat[i];
        const bool should_erase = exists ? c_lab != lab : true;
        
        if (should_erase)
        {
            m_in_category.erase(c_lab);
            m_label_ids.erase(c_lab);
        }
    }
    
    u64 category_idx = category_it->second;
    std::vector<u32>& labels = m_labels[category_idx];
    std::fill(labels.begin(), labels.end(), lab_id);
    
    if (!exists)
    {
        unchecked_insert_label(lab, lab_id, category);
    }
    
    m_progenitor_ids.randomize();
    
    return util::categorical_status::OK;
}

//  categories_match: True if another categorical has identical categories.

bool util::categorical::categories_match(const util::categorical &other) const
{
    if (n_categories() != other.n_categories())
    {
        return false;
    }
    
    for (const auto& it : m_category_indices)
    {
        if (other.m_category_indices.count(it.first) == 0)
        {
            return false;
        }
    }
    
    return true;
}

//  replace_labels: Replace label with single label.

util::u32 util::categorical::replace_labels(const std::string& from, const std::string& with)
{
    if (from == with)
    {
        return util::categorical_status::OK;
    }
    
    auto from_it = m_label_ids.find(from);
    auto with_it = m_label_ids.find(with);
    auto end_it = m_label_ids.endk();
    
    //  to-replace label does not exist
    if (from_it == end_it)
    {
        return util::categorical_status::OK;
    }
    
    //  replace-with label *does* exist, so have to
    //  merge some labels with the full replace_labels routine
    if (with_it != end_it)
    {
        std::vector<std::string> input = { from };
        bool test_scalar = false;
        return replace_labels(input, with, test_scalar);
    }
    
    const std::string c_incat = m_in_category.at(from);
    
    //  test whether we're trying to replace a label with the
    //  collapsed expression for the wrong category
    if (is_collapsed_expression_in_wrong_category(c_incat, with))
    {
        return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
    }
    
    //  otherwise, just change from -> with
    m_label_ids.insert(with, from_it->second);
    
    m_in_category.erase(from);
    m_in_category[with] = c_incat;
    
    //  string-label to uint32 mapping is now different
    m_progenitor_ids.randomize();
    
    return util::categorical_status::OK;
}

//  replace_labels: Replace labels with single label.

util::u32 util::categorical::replace_labels(const std::vector<std::string>& from,
                                            const std::string& with,
                                            bool test_scalar)
{
    u64 n_from = from.size();
    
    if (n_from == 0)
    {
        return util::categorical_status::OK;
    }
    else if (test_scalar && n_from == 1)
    {
        return replace_labels(from[0], with);
    }
    
    bool found_cat = false;
    std::string last_cat;
    std::unordered_set<u32> replace_ids;
    
    for (u64 i = 0; i < n_from; i++)
    {
        const std::string& c_from = from[i];
        
        if (!has_label(c_from))
        {
            continue;
        }
        
        const std::string& c_cat = m_in_category.at(c_from);
        
        if (found_cat && c_cat != last_cat)
        {
            return util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY;
        }
        
        found_cat = true;
        last_cat = c_cat;
        replace_ids.insert(m_label_ids.at(c_from));
    }
    
    //  nothing to replace
    if (!found_cat)
    {
        return util::categorical_status::OK;
    }
    
    bool with_exists = has_label(with);
    
    //  otherwise, if `with` exists, make sure it's in the right category
    if (with_exists && m_in_category.at(with) != last_cat)
    {
        return util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY;
    }
    
    if (is_collapsed_expression_in_wrong_category(last_cat, with))
    {
        return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
    }
    
    u32 with_id;
    
    if (with_exists)
    {
        with_id = m_label_ids.at(with);
    }
    else
    {
        with_id = get_next_label_id();
        m_in_category[with] = last_cat;
        m_label_ids.insert(with, with_id);
        m_progenitor_ids.randomize();
    }
    
    u64 cat_index = m_category_indices.at(last_cat);
    std::vector<u32>& col = m_labels[cat_index];
    u64 n_rows = col.size();
    
    for (u64 i = 0; i < n_rows; i++)
    {
        if (replace_ids.count(col[i]) > 0)
        {
            col[i] = with_id;
        }
    }
    
#ifdef CAT_PRUNE_AFTER_ASSIGN
    prune();
#endif
    
    return util::categorical_status::OK;
}

//  get_collapsed_expression: Get the string representation of a collapsed category.

std::string util::categorical::get_collapsed_expression(const std::string& for_cat) const
{
    return "<" + for_cat + ">";
}

//  keep: Retain rows at indices.

util::u32 util::categorical::keep(const std::vector<util::u64>& at_indices, util::u64 offset)
{
    const u64 n_indices = at_indices.size();
    const u64 sz = size();
    const u64 n_cats = m_labels.size();
    
    std::vector<std::vector<u32>> tmp(n_cats);
    
    for (u64 i = 0; i < n_cats; i++)
    {
        std::vector<u32>& tmp_col = tmp[i];
        std::vector<u32>& own_col = m_labels[i];
        
        tmp_col.resize(n_indices);
        
        for (u64 j = 0; j < n_indices; j++)
        {
            u64 idx = at_indices[j] - offset;
            
            if (idx >= sz)
            {
                return util::categorical_status::OUT_OF_BOUNDS;
            }
            
            tmp_col[j] = own_col[idx];
        }
    }
    
    m_labels = std::move(tmp);
    
    return util::categorical_status::OK;
}

//  remove: Remove rows associated with any among labels.

std::vector<util::u64> util::categorical::remove(const std::vector<std::string>& labels)
{
    const u64 n_labs = labels.size();
    const u64 sz = size();
    
    util::bit_array to_keep(sz, true);
    
    auto lab_it_end = m_label_ids.endk();
    
    for (u64 i = 0; i < n_labs; i++)
    {
        const std::string& lab = labels[i];
        const auto lab_it = m_label_ids.find(lab);
        
        //  label doesn't exist
        if (lab_it == lab_it_end)
        {
            continue;
        }
        
        const u32 lab_id = lab_it->second;
        const std::string& cat = m_in_category.at(lab);
        const u64 cat_idx = m_category_indices.at(cat);
        const std::vector<util::u32>& lab_col = m_labels[cat_idx];
        
        util::bit_array lab_idx = util::categorical::assign_bit_array(lab_col, lab_id);
        
        util::bit_array::unchecked_dot_and_not(to_keep, to_keep, lab_idx, 0, sz);
    }
    
    std::vector<u64> keep_inds = util::bit_array::findv(to_keep);
    
    util::categorical::keep(keep_inds);
    
    return keep_inds;
}

//  empty: Retain 0 rows, and prune missing labels.

void util::categorical::empty()
{
    reserve(0);
}

//  prune: Remove labels wihout rows.

util::u64 util::categorical::prune()
{
    const u64 n_cats = m_labels.size();
    
    auto copy_ids = m_label_ids;
    std::unordered_set<u32> visited;
    
    for (u64 i = 0; i < n_cats; i++)
    {
        const std::vector<u32>& labs = m_labels[i];
        u64 n_labs = labs.size();
        
        for (u64 j = 0; j < n_labs; j++)
        {
            u32 lab = labs[j];
            
            if (visited.count(lab) == 0)
            {
                copy_ids.erase(lab);
                visited.insert(lab);
            }
        }
    }
    
    std::vector<u32> remaining = copy_ids.values();
    u64 n_remaining = remaining.size();
    
    for (u64 i = 0; i < n_remaining; i++)
    {
        const u32 id = remaining[i];
        const std::string& lab = m_label_ids.at(id);
        m_in_category.erase(lab);
        m_label_ids.erase(id);
    }
    
    if (n_remaining > 0)
    {
        m_progenitor_ids.randomize();
    }
    
    return n_remaining;
}

void util::categorical::unchecked_append_progenitors_match(const util::categorical& other,
                                                           util::u64 own_sz,
                                                           util::u64 other_sz)
{
    resize(own_sz + other_sz);
    
    u64 n_cols = m_labels.size();
    
    size_t n_copy = other_sz * sizeof(util::u32);
    
    for (u64 i = 0; i < n_cols; i++)
    {
        util::u32* dest_ptr = m_labels[i].data();
        const util::u32* src_ptr = other.m_labels[i].data();
        std::memcpy(dest_ptr + own_sz, src_ptr, n_copy);
    }
}

util::u32 util::categorical::unchecked_append_progenitors_match_indexed(const util::categorical& other,
                                                                        util::u64 own_sz,
                                                                        util::u64 other_sz,
                                                                        const std::vector<util::u64>& indices,
                                                                        util::u64 index_offset)
{
    const u64 indices_sz = indices.size();
    resize(own_sz + indices_sz);
    const u64 n_cols = m_labels.size();
    
    for (u64 i = 0; i < n_cols; i++)
    {
        util::u32* dest_ptr = m_labels[i].data();
        const util::u32* src_ptr = other.m_labels[i].data();
        
        for (u64 j = 0; j < indices_sz; j++)
        {
            const u64 idx = indices[j] - index_offset;
            
            if (idx >= other_sz)
            {
                resize(own_sz);
                return util::categorical_status::OUT_OF_BOUNDS;
            }
            
            dest_ptr[own_sz + j] = src_ptr[idx];
        }
    }
    
    return util::categorical_status::OK;
}

//  append_one: Append another categorical object, collapsing
//      its non-uniform categories

util::u32 util::categorical::append_one(const util::categorical& other)
{
    return append_one_impl(other, false, std::vector<util::u64>(), 0, 0);
}

//  append_one: Append another categorical object, collapsing
//      its non-uniform categories, for indexed subset.

util::u32 util::categorical::append_one(const util::categorical& other,
                                        const std::vector<util::u64>& indices,
                                        util::u64 index_offset,
                                        util::u64 repetitions)
{
    return append_one_impl(other, true, indices, index_offset, repetitions);
}

util::u32 util::categorical::append_one_impl(const util::categorical& other,
                                             const bool use_indices,
                                             const std::vector<util::u64>& indices,
                                             util::u64 index_offset,
                                             util::u64 repetitions)
{
    if (other.size() == 0)
    {
        return util::categorical_status::OK;
    }
    
    if (use_indices && indices.size() == 0)
    {
        return util::categorical_status::OK;
    }
    
    categorical tmp;
    
    for (const auto& cat_it : other.m_category_indices)
    {
        const std::string& cat = cat_it.first;
        
        tmp.require_category(cat);
        
        const std::vector<u32>& ids = other.m_labels[cat_it.second];
        
        bool is_uniform;
        
        if (use_indices)
        {
            u32 status;
            is_uniform = other.is_uniform(ids, indices, &status, index_offset);
            
            if (status != util::categorical_status::OK)
            {
                return status;
            }
        }
        else
        {
            is_uniform = other.is_uniform(ids);
        }
        
        std::string assign_lab;
        
        if (is_uniform)
        {
            u64 idx = 0;
            
            if (use_indices)
            {
                idx = indices[0] - index_offset;
            }
            
            assign_lab = other.m_label_ids.at(ids[idx]);
        }
        else
        {
            assign_lab = other.get_collapsed_expression(cat);
        }
        
        tmp.set_category(cat, {assign_lab});
    }
    
    tmp.prune();
    tmp.repeat(repetitions);
    
    return append(tmp);
}

//  append: Append one categorical object to another.

util::u32 util::categorical::append(const util::categorical &other)
{
    return append_impl(other, false, std::vector<util::u64>(), 0);
}

util::u32 util::categorical::append(const util::categorical &other,
                                    const std::vector<util::u64>& indices,
                                    util::u64 index_offset)
{
    return append_impl(other, true, indices, index_offset);
}

util::u32 util::categorical::append_impl(const util::categorical& other,
                                         const bool use_indices,
                                         const std::vector<util::u64>& indices,
                                         util::u64 index_offset)
{
    const u64 other_sz = use_indices ? indices.size() : other.size();
    const u64 own_sz = size();
    
    if (other_sz == 0)
    {
        return util::categorical_status::OK;
    }
    
    if (own_sz == 0)
    {
        if (use_indices)
        {
            util::categorical tmp = other;
            
            u32 status = tmp.keep(indices, index_offset);
            
            if (status != util::categorical_status::OK)
            {
                return status;
            }
            
            *this = std::move(tmp);
        }
        else
        {
            *this = other;
        }
        
        return util::categorical_status::OK;
    }
    
    if (!categories_match(other))
    {
        return util::categorical_status::CATEGORIES_DO_NOT_MATCH;
    }
    
    u64 int_max = ~(u64(0));
    
    if (int_max - own_sz < other_sz)
    {
        return util::categorical_status::CAT_OVERFLOW;
    }
    
    if (m_progenitor_ids == other.m_progenitor_ids)
    {
        if (use_indices)
        {
            return unchecked_append_progenitors_match_indexed(other, own_sz, other.size(), indices, index_offset);
        }
        else
        {
            unchecked_append_progenitors_match(other, own_sz, other_sz);
            return util::categorical_status::OK;
        }
    }
    
    std::unordered_map<u32, u32> replace_other_labs;
    
    auto tmp_label_ids = m_label_ids;
    auto tmp_in_cat = m_in_category;
    
    util::u32 new_labels_status = reconcile_new_label_ids(other, tmp_label_ids, tmp_in_cat, replace_other_labs);
    
    if (new_labels_status != util::categorical_status::OK)
    {
        return new_labels_status;
    }
    
    util::u32 collapsed_cat_status = merge_check_collapsed_expressions(other);
    
    if (collapsed_cat_status != util::categorical_status::OK)
    {
        return collapsed_cat_status;
    }
    
    //  if we get here, all is well.
    u64 orig_n_labels = m_label_ids.size();
    u64 new_n_labels = tmp_label_ids.size();
    
    if (new_n_labels > orig_n_labels)
    {
        m_progenitor_ids.randomize();
    }
    
    m_label_ids = std::move(tmp_label_ids);
    m_in_category = std::move(tmp_in_cat);
    
    resize(own_sz + other_sz);
    
    if (use_indices)
    {
        util::u32 status = append_fill_new_label_ids_indexed(other, replace_other_labs, own_sz, other.size(), indices, index_offset);
        
        if (status != util::categorical_status::OK)
        {
            resize(own_sz);
        }
        
        return status;
    }
    else
    {
        append_fill_new_label_ids(other, replace_other_labs, own_sz, other_sz);
        return util::categorical_status::OK;
    }
}

void util::categorical::append_fill_new_label_ids(const util::categorical& other,
                                                  const std::unordered_map<util::u32, util::u32>& replace_other_labs,
                                                  util::u64 own_sz,
                                                  util::u64 other_sz)
{
    const size_t n_copy = other_sz * sizeof(util::u32);
    
    for (const auto& it : m_category_indices)
    {
        const std::string& cat = it.first;
        const util::u64 own_idx = it.second;
        const util::u64 other_idx = other.m_category_indices.at(cat);
        
        const util::u32* src = other.m_labels[other_idx].data();
        util::u32* dest = m_labels[own_idx].data();
        
        std::memcpy(dest + own_sz, src, n_copy);
        
        for (util::u64 i = 0; i < other_sz; i++)
        {
            util::u32 id = dest[i + own_sz];
            
            if (replace_other_labs.count(id) > 0)
            {
                dest[i + own_sz] = replace_other_labs.at(id);
            }
        }
    }
}

util::u32 util::categorical::append_fill_new_label_ids_indexed(const util::categorical& other,
                                                               const std::unordered_map<util::u32, util::u32>& replace_other_labs,
                                                               util::u64 own_sz,
                                                               util::u64 other_sz,
                                                               const std::vector<util::u64>& indices,
                                                               util::u64 index_offset)
{
    const u64 n_indices = indices.size();
    
    for (const auto& it : m_category_indices)
    {
        const std::string& cat = it.first;
        const u64 own_idx = it.second;
        const u64 other_idx = other.m_category_indices.at(cat);
        
        const u32* src = other.m_labels[other_idx].data();
        u32* dest = m_labels[own_idx].data();
        
        for (u64 i = 0; i < n_indices; i++)
        {
            u64 idx = indices[i] - index_offset;
            
            if (idx >= other_sz)
            {
                return util::categorical_status::OUT_OF_BOUNDS;
            }
            
            u32 id = src[idx];
            
            if (replace_other_labs.count(id) > 0)
            {
                id = replace_other_labs.at(id);
            }
            
            dest[i + own_sz] = id;
        }
    }
    
    return util::categorical_status::OK;
}

//  replace_labels: Helper function to replace outgoing label ids with new ids.

void util::categorical::replace_labels(std::vector<std::vector<u32>>& labels,
                                       util::u64 start, util::u64 stop,
                                       const std::unordered_map<util::u32, util::u32>& replace_map)
{
    using util::u64;
    
    if (replace_map.size() == 0)
    {
        return;
    }
    
    u64 cols = labels.size();
    
    for (u64 i = 0; i < cols; i++)
    {
        std::vector<u32>& c_cat = labels[i];
        
        for (u64 j = start; j < stop; j++)
        {
            u32 c_lab = c_cat[j];
            
            if (replace_map.count(c_lab) > 0)
            {
                c_cat[j] = replace_map.at(c_lab);
            }
        }
    }
}

//  unchecked_assign_progenitors_match: Assign contents at indices, assuming progenitors match.

void util::categorical::unchecked_assign_progenitors_match(const util::categorical& other,
                                                           const std::vector<util::u64>& to_indices,
                                                           util::u64 index_offset)
{
    const u64 n_cols = m_labels.size();
    const u64 n_indices = to_indices.size();
    
    for (u64 i = 0; i < n_cols; i++)
    {
        std::vector<u32>& own_labs = m_labels[i];
        const std::vector<u32>& other_labs = other.m_labels[i];
        
        for (u64 j = 0; j < n_indices; j++)
        {
            u64 to_idx = to_indices[j] - index_offset;
            own_labs[to_idx] = other_labs[j];
        }
    }
}

//  unchecked_assign_progenitors_match: Assign contents at indices, assuming progenitors match.

void util::categorical::unchecked_assign_progenitors_match(const util::categorical &other,
                                                           const std::vector<util::u64> &to_indices,
                                                           const std::vector<util::u64> &from_indices,
                                                           util::u64 index_offset,
                                                           bool is_scalar)
{
    const u64 n_cols = m_labels.size();
    const u64 n_indices = to_indices.size();
    
    for (u64 i = 0; i < n_cols; i++)
    {
        std::vector<u32>& own_labs = m_labels[i];
        const std::vector<u32>& other_labs = other.m_labels[i];
        
        for (u64 j = 0; j < n_indices; j++)
        {
            const u64 ind_from = is_scalar ? 0 : j;
            u64 from_idx = from_indices[ind_from] - index_offset;
            u64 to_idx = to_indices[j] - index_offset;
            own_labs[to_idx] = other_labs[from_idx];
        }
    }
}

//  assign: Assign contents at indices.

util::u32 util::categorical::assign(const util::categorical& other,
                                    const std::vector<util::u64>& at_indices,
                                    util::u64 index_offset)
{
    if (!categories_match(other))
    {
        return util::categorical_status::CATEGORIES_DO_NOT_MATCH;
    }
    
    const u64 n_indices = at_indices.size();
    const u64 own_sz = size();
    const u64 other_sz = other.size();
    
    //  error if the number of indices doesn't match
    //  the size of the incoming array.
    if (n_indices != other_sz)
    {
        return util::categorical_status::WRONG_INDEX_SIZE;
    }
    
    //  error if assigning more rows than exist in the array.
    if (other_sz > own_sz)
    {
        return util::categorical_status::OUT_OF_BOUNDS;
    }
    
    if (other_sz == 0)
    {
        return util::categorical_status::OK;
    }
    
    //  bounds check
    
    const u32 bounds_status = util::categorical::bounds_check(at_indices.data(), n_indices, own_sz, index_offset);
    
    if (bounds_status != util::categorical_status::OK)
    {
        return bounds_status;
    }
    
    if (m_progenitor_ids == other.m_progenitor_ids)
    {
        unchecked_assign_progenitors_match(other, at_indices, index_offset);
        return util::categorical_status::OK;
    }
    
    m_progenitor_ids.randomize();
    
    std::vector<std::string> other_labels = other.m_label_ids.keys();
    u64 n_other_labels = other_labels.size();
    
    std::unordered_map<u32, u32> replace_other_label_ids;
    std::unordered_set<u32> new_label_ids;
    
    for (u64 i = 0; i < n_other_labels; i++)
    {
        const std::string& other_lab = other_labels[i];
        const u32 other_id = other.m_label_ids.at(other_lab);
        
        auto own_id_it = m_label_ids.find(other_lab);
        
        //  label exists in `this`
        if (own_id_it != m_label_ids.endk())
        {
            const std::string& own_cat = m_in_category.at(other_lab);
            const std::string& other_cat = other.m_in_category.at(other_lab);
            
            if (own_cat != other_cat)
            {
                //  get rid of label ids that were added.
                prune();
                return util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY;
            }
            
            u32 own_id = m_label_ids.at(other_lab);
            
            if (own_id != other_id)
            {
                replace_other_label_ids[other_id] = own_id;
            }
        }
        else
        {
            u32 assign_id = other_id;
            
            if (m_label_ids.contains(other_id))
            {
                u32 new_id = util::categorical::get_id(this, &other, new_label_ids);
                replace_other_label_ids[other_id] = new_id;
                new_label_ids.insert(new_id);
                assign_id = new_id;
            }
            
            unchecked_insert_label(other_lab, assign_id, other.m_in_category.at(other_lab));
        }
    }
    
    for (const auto& cat_it : m_category_indices)
    {
        const std::string& cat = cat_it.first;
        const u64 own_cat_idx = cat_it.second;
        const u64 other_cat_idx = other.m_category_indices.at(cat);
        
        std::vector<u32>& own_ids = m_labels[own_cat_idx];
        const std::vector<u32>& other_ids = other.m_labels[other_cat_idx];
        
        for (u64 i = 0; i < n_indices; i++)
        {
            const u64 own_idx = at_indices[i] - index_offset;
            u32 other_id = other_ids[i];
            
            if (replace_other_label_ids.count(other_id) > 0)
            {
                other_id = replace_other_label_ids[other_id];
            }
            
            own_ids[own_idx] = other_id;
        }
    }
    
#ifdef CAT_PRUNE_AFTER_ASSIGN
    prune();
#endif
    
    return util::categorical_status::OK;
}

util::u32 util::categorical::assign(const util::categorical& other,
                                    const std::vector<util::u64>& to_indices,
                                    const std::vector<util::u64>& from_indices,
                                    util::u64 index_offset)
{
    if (!categories_match(other))
    {
        return util::categorical_status::CATEGORIES_DO_NOT_MATCH;
    }
    
    u64 n_to_indices = to_indices.size();
    u64 n_from_indices = from_indices.size();
    u64 own_sz = size();
    u64 other_sz = other.size();
    
    bool is_scalar = false;
    
    //  error if n from indices does not match n to indices,
    //  and n_from_indices isn't scalar
    if (n_to_indices != n_from_indices)
    {
        if (n_from_indices == 1)
        {
            is_scalar = true;
        }
        else
        {
            return util::categorical_status::WRONG_INDEX_SIZE;
        }
    }
    
    //  bounds check
    u32 own_status = util::categorical::bounds_check(to_indices.data(), n_to_indices, own_sz, index_offset);
    u32 other_status = util::categorical::bounds_check(from_indices.data(), n_from_indices, other_sz, index_offset);
    u32 ok = util::categorical_status::OK;
    
    if (own_status != ok || other_status != ok)
    {
        return own_status;
    }
    
    if (m_progenitor_ids == other.m_progenitor_ids)
    {
        unchecked_assign_progenitors_match(other, to_indices, from_indices, index_offset, is_scalar);
        return util::categorical_status::OK;
    }
    m_progenitor_ids.randomize();
    
    std::unordered_map<u32, u32> replace_other_label_ids;
    std::unordered_set<u32> new_label_ids;
    
#ifdef CAT_COPY_ASSIGN_FROM
    std::vector<std::vector<u32>> copy_own_labs = m_labels;
#endif
    
    for (const auto& cat_it : m_category_indices)
    {
        const std::string& own_cat = cat_it.first;
        const u64 own_cat_idx = cat_it.second;
        const u64 other_cat_idx = other.m_category_indices.at(own_cat);
        
#ifdef CAT_COPY_ASSIGN_FROM
        std::vector<u32>& own_labs = copy_own_labs[own_cat_idx];
#else
        std::vector<u32>& own_labs = m_labels[own_cat_idx];
#endif
        const std::vector<u32>& other_labs = other.m_labels[other_cat_idx];
        
        for (u64 i = 0; i < n_to_indices; i++)
        {
            const u64 index_from = is_scalar ? 0 : i;
            const u64 from_idx = from_indices[index_from] - index_offset;
            const u64 to_idx = to_indices[i] - index_offset;
            
            const u32 other_lab_id = other_labs[from_idx];
            
            if (replace_other_label_ids.count(other_lab_id) > 0)
            {
                own_labs[to_idx] = replace_other_label_ids.at(other_lab_id);
                continue;
            }
            
            //
            //  not yet processed
            //
            const std::string& str_lab = other.m_label_ids.at(other_lab_id);
            const std::string& other_cat = other.m_in_category.at(str_lab);
            
            auto own_lab_it = m_label_ids.find(str_lab);
            
            u32 assign_id = other_lab_id;
            
            //  label exists
            if (own_lab_it != m_label_ids.endk())
            {
                if (m_in_category.at(str_lab) != other_cat)
                {
                    //  get rid of added labels
                    prune();
                    
                    return util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY;
                }
                
                u32 own_lab_id = m_label_ids.at(str_lab);
                
                if (own_lab_id != other_lab_id)
                {
                    assign_id = own_lab_id;
                }
            }
            else
            {
                if (m_label_ids.contains(other_lab_id))
                {
                    u32 new_id = util::categorical::get_id(this, &other, new_label_ids);
                    new_label_ids.insert(new_id);
                    assign_id = new_id;
                }
                
                unchecked_insert_label(str_lab, assign_id, other_cat);
            }
            
            replace_other_label_ids[other_lab_id] = assign_id;
            
            own_labs[to_idx] = assign_id;
        }
    }
    
#ifdef CAT_COPY_ASSIGN_FROM
    m_labels = std::move(copy_own_labs);
#endif
#ifdef CAT_PRUNE_AFTER_ASSIGN
    prune();
#endif
    
    return util::categorical_status::OK;
}

util::u32 util::categorical::merge(const util::categorical& other, const bool overwrite_existing_cats)
{
    const u64 own_sz = size();
    const u64 other_sz = other.size();
    
    bool is_scalar = other_sz == 1;
    bool sizes_match = own_sz == other_sz;
    
    if (!sizes_match && !is_scalar)
    {
        return util::categorical_status::INCOMPATIBLE_SIZES;
    }
    
    std::unordered_map<u32, u32> replace_other_labs;
    
    auto tmp_label_ids = m_label_ids;
    auto tmp_in_cat = m_in_category;
    
    util::u32 new_labels_status = reconcile_new_label_ids(other, tmp_label_ids, tmp_in_cat,
                                                          replace_other_labs, overwrite_existing_cats);
    
    if (new_labels_status != util::categorical_status::OK)
    {
        return new_labels_status;
    }
    
    util::u32 collapsed_cat_status = merge_check_collapsed_expressions(other, overwrite_existing_cats);
    
    if (collapsed_cat_status != util::categorical_status::OK)
    {
        return collapsed_cat_status;
    }
    
    std::vector<std::string> new_categories;
    util::u32 require_cat_status = merge_require_categories(other, new_categories);
    
    if (require_cat_status != util::categorical_status::OK)
    {
        return require_cat_status;
    }
    
    //  if we get here, all is well.
    const u64 orig_n_labels = m_label_ids.size();
    const u64 new_n_labels = tmp_label_ids.size();
    
    if (new_n_labels > orig_n_labels)
    {
        m_progenitor_ids.randomize();
    }
    
    m_label_ids = std::move(tmp_label_ids);
    m_in_category = std::move(tmp_in_cat);
    
    const auto& cats_to_check = overwrite_existing_cats ? other.get_categories() : new_categories;
    
    merge_fill_new_label_ids(other, cats_to_check, replace_other_labs, is_scalar, sizes_match, own_sz);
    
    return util::categorical_status::OK;
}

//  merge: Merge array contents.

util::u32 util::categorical::merge(const util::categorical& other)
{
    const bool overwrite_existing_cats = true;
    return merge(other, overwrite_existing_cats);
}

//  merge_new: Merge array contents, preserving existing categories.

util::u32 util::categorical::merge_new(const util::categorical& other)
{
    const bool overwrite_existing_cats = false;
    return merge(other, overwrite_existing_cats);
}

void util::categorical::merge_fill_new_label_ids(const util::categorical& other,
                                                 const std::vector<std::string>& categories,
                                                 std::unordered_map<util::u32, util::u32>& replace_other_labs,
                                                 bool is_scalar,
                                                 bool sizes_match,
                                                 util::u64 own_sz)
{
    for (const auto& cat : categories)
    {
        u64 own_idx = m_category_indices.at(cat);
        u64 other_idx = other.m_category_indices.at(cat);
        
        m_labels[own_idx] = other.m_labels[other_idx];
        
        std::vector<u32>& col = m_labels[own_idx];
        
        if (is_scalar && !sizes_match)
        {
            col.resize(own_sz);
            std::fill(col.begin(), col.end(), other.m_labels[other_idx][0]);
        }
        
        for (u64 j = 0; j < own_sz; j++)
        {
            u32 id = col[j];
            
            if (replace_other_labs.count(id) > 0)
            {
                col[j] = replace_other_labs.at(id);
            }
        }
    }
}

util::u32 util::categorical::merge_check_collapsed_expressions(const util::categorical &other,
                                                               const bool overwrite_existing_categories) const
{
    for (const auto& it : m_category_indices)
    {
        const std::string& cat = it.first;
        const std::string collapsed_expression = get_collapsed_expression(cat);
        
        if (other.has_label(collapsed_expression))
        {
            const std::string& other_cat = other.m_in_category.at(collapsed_expression);
            const bool wrong_cat = other_cat != cat && (overwrite_existing_categories || !has_category(other_cat));
            
            if (wrong_cat)
            {
                return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
            }
        }
    }
    
    return util::categorical_status::OK;
}

util::u32 util::categorical::merge_require_categories(const util::categorical& other,
                                                      std::vector<std::string>& new_categories)
{
    for (const auto& it : other.m_category_indices)
    {
        const std::string& cat = it.first;
        
        if (!has_category(cat))
        {
            new_categories.push_back(cat);
        }
        
        const util::u32 cat_status = require_category(cat);
        
        if (cat_status != util::categorical_status::OK)
        {
            for (const auto& c_cat : new_categories)
            {
                bool dummy;
                remove_category(c_cat, &dummy);
            }
            
            return cat_status;
        }
    }
    
    return util::categorical_status::OK;
}

//  reconcile_new_label_ids: Create new label ids for incoming labels.

util::u32 util::categorical::reconcile_new_label_ids(const util::categorical& other,
                                                     util::multimap<std::string, util::u32>& tmp_label_ids,
                                                     std::unordered_map<std::string, std::string>& tmp_in_cat,
                                                     std::unordered_map<util::u32, util::u32>& replace_other,
                                                     const bool overwrite_existing_categories) const
{
    std::unordered_set<util::u32> new_label_ids;
    
    std::vector<std::string> other_labs = other.m_label_ids.keys();
    
    auto own_lab_it_end = m_label_ids.endk();
    
    u64 n_other_labs = other_labs.size();
    
    for (u64 i = 0; i < n_other_labs; i++)
    {
        const std::string& other_lab = other_labs[i];
        const std::string& other_in_cat = other.m_in_category.at(other_lab);
        
        if (!overwrite_existing_categories && has_category(other_in_cat))
        {
            continue;
        }
        
        auto own_lab_it = m_label_ids.find(other_lab);
        util::u32 other_id = other.m_label_ids.at(other_lab);
        
        //  this label exists
        if (own_lab_it != own_lab_it_end)
        {
            const std::string& own_in_cat = m_in_category.at(other_lab);
            
            if (own_in_cat != other_in_cat)
            {
                return util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY;
            }
            
            util::u32 own_id = own_lab_it->second;
            
            if (own_id != other_id)
            {
                replace_other[other_id] = own_id;
            }
        }
        else
        {            
            //  label is new
            util::u32 replace_id = other_id;
            
            if (m_label_ids.contains(other_id))
            {
                replace_id = util::categorical::get_id(this, &other, new_label_ids);
                new_label_ids.insert(replace_id);
                replace_other[other_id] = replace_id;
            }
            
            tmp_label_ids.insert(other_lab, replace_id);
            tmp_in_cat[other_lab] = other_in_cat;
        }
    }
    
    return util::categorical_status::OK;
}

//  bounds_check: Ensure incoming indices are in bounds.

util::u32 util::categorical::bounds_check(const util::u64* data,
                                          util::u64 n_check,
                                          util::u64 end,
                                          util::u64 index_offset)
{
    for (u64 i = 0; i < n_check; i++)
    {
        if (data[i] - index_offset >= end)
        {
            return util::categorical_status::OUT_OF_BOUNDS;
        }
    }
    
    return util::categorical_status::OK;
}

//  get_uniform_categories: Get categories that have only a single label.

std::vector<std::string> util::categorical::get_uniform_categories() const
{
    std::vector<std::string> cats;
    
    for (const auto& cat_it : m_category_indices)
    {
        const u64 cat_idx = cat_it.second;
        const std::string& cat = cat_it.first;
        
        const std::vector<u32>& labs = m_labels[cat_idx];
        
        if (is_uniform(labs))
        {
            cats.push_back(cat);
        }
    }
    
    //  sort category names
    std::sort(cats.begin(), cats.end());
    
    return cats;
}

//  get_categories: Get all string categories.

std::vector<std::string> util::categorical::get_categories() const
{
    std::vector<std::string> cats(n_categories());
    
    util::u64 i = 0;
    
    for (const auto& it : m_category_indices)
    {
        cats[i++] = it.first;
    }
    
    //  Important: sort category names
    std::sort(cats.begin(), cats.end());
    
    return cats;
}

//  get_categories_except: Get all categories, except those in `others`.

std::vector<std::string> util::categorical::get_categories_except(const std::vector<std::string>& others) const
{
    std::vector<std::string> all_categories = get_categories();
    std::vector<std::string> sorted_categories = others;
    
    std::sort(sorted_categories.begin(), sorted_categories.end());
    auto categories_end = std::unique(sorted_categories.begin(), sorted_categories.end());
    
    std::vector<std::string> difference;
    std::set_difference(all_categories.begin(), all_categories.end(),
                        sorted_categories.begin(), categories_end,
                        std::back_inserter(difference));
    
    return difference;
}

//  get_labels: Get all string labels.

std::vector<std::string> util::categorical::get_labels() const
{
    std::vector<std::string> labs = m_label_ids.keys();
    std::sort(labs.begin(), labs.end());
    return labs;
}

//  get_labels_and_ids: Get labels and numeric labels

util::labels_t util::categorical::get_labels_and_ids() const
{
    std::vector<std::string> labs = get_labels();
    util::u64 n_labs = labs.size();
    std::vector<util::u32> ids(n_labs);
    
    for (util::u64 i = 0; i < n_labs; i++)
    {
        ids[i] = m_label_ids.at(labs[i]);
    }
    
    return { ids, labs };
}

//  get_label_mat: Get a reference to the labels array, where columns
//      are ordered by category.

std::vector<const std::vector<util::u32>*> util::categorical::get_label_mat() const
{
    bool dummy;
    return get_label_mat(get_categories(), &dummy);
}

//  get_label_mat: Get a reference to the labels array, in subset of categories.

std::vector<const std::vector<util::u32>*> util::categorical::get_label_mat(const std::vector<std::string>& cats,
                                                                            bool* exists) const
{
    *exists = true;
    util::u64 n_cats = cats.size();
    std::vector<const std::vector<util::u32>*> res(n_cats);
    auto cat_end = m_category_indices.end();
    
    for (util::u64 i = 0; i < n_cats; i++)
    {
        auto it = m_category_indices.find(cats[i]);
        
        if (it == cat_end)
        {
            *exists = false;
        }
        else
        {
            util::u64 cat_idx = it->second;
            res[i] = &m_labels[cat_idx];
        }
    }
    
    return res;
}

//  partial_category: Replace int label ids with string labels, for a subset of rows.
//
//      Pass in pointer to `exists` to verify that
//      the category exists.

std::vector<std::string> util::categorical::partial_category(const std::string &category,
                                                             const std::vector<util::u64>& at_indices,
                                                             util::u32* status,
                                                             util::u64 index_offset) const
{
    using util::u64;
    using util::u32;
    
    const auto cat_it = m_category_indices.find(category);
    
    std::vector<std::string> result;
    
    if (cat_it == m_category_indices.end())
    {
        *status = util::categorical_status::CATEGORY_DOES_NOT_EXIST;
        return result;
    }
    
    const std::vector<u32>& labs = m_labels[cat_it->second];
    
    u64 n_indices = at_indices.size();
    u64 sz = size();
    
    for (u64 i = 0; i < n_indices; i++)
    {
        u64 idx = at_indices[i] - index_offset;
        
        if (idx >= sz)
        {
            *status = util::categorical_status::OUT_OF_BOUNDS;
            result.resize(0);
            return result;
        }
        
        result.push_back(m_label_ids.at(labs[idx]));
    }
    
    *status = util::categorical_status::OK;
    
    return result;
}

//  full_category: Replace int label ids with string labels.
//
//      Pass in pointer to `exists` to verify that
//      the category exists.

std::vector<std::string> util::categorical::full_category(const std::string &category, bool *exists) const
{
    const auto cat_it = m_category_indices.find(category);
    
    std::vector<std::string> result;
    
    if (cat_it == m_category_indices.end())
    {
        *exists = false;
        return result;
    }
    
    *exists = true;
    
    util::u64 sz = size();
    
    result.resize(sz);
    
    const std::vector<util::u32>& ids = m_labels[cat_it->second];
    
    for (util::u64 i = 0; i < sz; i++)
    {
        std::string lab = m_label_ids.at(ids[i]);
        result[i] = lab;
    }
    
    return result;
}

//  full_category: Replace int label ids with string labels.
//
//      If the category does not exist, the result is an empty vector.

std::vector<std::string> util::categorical::full_category(const std::string &category) const
{
    bool dummy;
    return full_category(category, &dummy);
}

//  is_uniform_category: True if the category has a single label id.

bool util::categorical::is_uniform_category(const std::string& cat, bool* exists) const
{
    using util::u64;
    using util::u32;
    
    *exists = true;
    
    auto cat_it = m_category_indices.find(cat);
    
    if (cat_it == m_category_indices.end())
    {
        *exists = false;
        return false;
    }
    
    const std::vector<u32>& lab_ids = m_labels[cat_it->second];
    
    return is_uniform(lab_ids);
}

//  is_uniform_category: True if the category has a single label id, for subset of rows.

bool util::categorical::is_uniform_category(const std::string &cat,
                                            const std::vector<util::u64>& indices,
                                            util::u32 *status,
                                            util::u64 index_offset) const
{
    using util::u64;
    using util::u32;
    
    *status = util::categorical_status::OK;
    
    auto cat_it = m_category_indices.find(cat);
    
    if (cat_it == m_category_indices.end())
    {
        *status = util::categorical_status::CATEGORY_DOES_NOT_EXIST;
        return false;
    }
    
    const std::vector<u32>& lab_ids = m_labels[cat_it->second];
    
    return is_uniform(lab_ids, indices, status, index_offset);
}

std::vector<bool> util::categorical::are_uniform_categories(const std::vector<std::string>& cats, bool* exists) const
{
    std::vector<bool> result;
    
    for (const auto& cat : cats)
    {
        result.push_back(is_uniform_category(cat, exists));
        
        if (!*exists)
        {
            return std::vector<bool>();
        }
    }
    
    return result;
}

std::vector<bool> util::categorical::are_uniform_categories(const std::vector<std::string>& cats,
                                                            const std::vector<util::u64>& indices,
                                                            util::u32* status,
                                                            util::u64 index_offset) const
{
    std::vector<bool> result;
    
    for (const auto& cat : cats)
    {
        result.push_back(is_uniform_category(cat, indices, status, index_offset));
        
        if (*status != categorical_status::OK)
        {
            return std::vector<bool>();
        }
    }
    
    return result;
}

bool util::categorical::is_uniform(const std::vector<util::u32>& lab_ids) const
{
    using util::u64;
    using util::u32;
    
    const u64 sz = lab_ids.size();
    
    if (sz == 0)
    {
        return true;
    }
    
    u32 last = lab_ids[0];
    
    for (u64 i = 1; i < sz; i++)
    {
        if (lab_ids[i] != last)
        {
            return false;
        }
    }
    
    return true;
}

bool util::categorical::is_uniform(const std::vector<util::u32>& lab_ids,
                                   const std::vector<util::u64>& indices,
                                   util::u32* status,
                                   util::u64 index_offset) const
{
    const u64 n_indices = indices.size();
    const u64 sz = lab_ids.size();
    
    *status = util::categorical_status::OK;
    
    if (n_indices == 0)
    {
        return false;
    }
    
    u64 first = indices[0] - index_offset;
    
    if (first >= sz)
    {
        *status = util::categorical_status::OUT_OF_BOUNDS;
        return false;
    }
    
    u32 last = lab_ids[first];
    
    for (u64 i = 1; i < n_indices; i++)
    {
        u64 idx = indices[i] - index_offset;
        
        if (idx >= sz)
        {
            *status = util::categorical_status::OUT_OF_BOUNDS;
            return false;
        }
        
        if (lab_ids[idx] != last)
        {
            return false;
        }
    }
    
    return true;
}

//  which_category: Determine the category in which a label resides.
//
//      Pass in pointer to `exists` to verify that
//      the label exists.

std::string util::categorical::which_category(const std::string& label, bool* exists) const
{
    if (!has_label(label))
    {
        *exists = false;
        return std::string();
    }
    
    *exists = true;
    return m_in_category.find(label)->second;
}

//  in_category: Get all labels in a category.
//
//      Pass in pointer to `exists` to verify that
//      the category exists.

std::vector<std::string> util::categorical::in_category(const std::string& category, bool* exists) const
{
    std::vector<std::string> result;
    
    if (!has_category(category))
    {
        *exists = false;
        return result;
    }
    
    *exists = true;
    unchecked_in_category(result, category);
    return result;
}

//  in_category: Get all labels in a category.
//
//      If the category does not exist, the result is an empty vector.

std::vector<std::string> util::categorical::in_category(const std::string& category) const
{
    std::vector<std::string> result;
    unchecked_in_category(result, category);
    return result;
}

std::vector<std::string> util::categorical::in_categories(const std::vector<std::string>& categories,
                                                          bool* exist) const
{
    if (!has_categories(categories))
    {
        *exist = false;
        return {};
    }
    
    *exist = true;
    
    std::vector<std::string> result;
    std::vector<std::string> labs = m_label_ids.keys();
    
    for (const auto& cat : categories)
    {
        for (const auto& lab : labs)
        {
            if (m_in_category.at(lab) == cat)
            {
                result.push_back(lab);
            }
        }
    }

    return result;
}

void util::categorical::unchecked_in_category(std::vector<std::string>& out, const std::string& category) const
{
    std::vector<std::string> labs = m_label_ids.keys();
    util::u64 n_labs = labs.size();
    
    for (util::u64 i = 0; i < n_labs; i++)
    {
        const std::string& lab = labs[i];
        
        if (m_in_category.at(lab) == category)
        {
            out.push_back(lab);
        }
    }
}

//  remove_category: Remove category and all labels therein.

void util::categorical::remove_category(const std::string& category, bool* exists)
{
    std::vector<std::string> labs = in_category(category, exists);
    
    if (!(*exists))
    {
        return;
    }
    
    util::u64 cat_index = m_category_indices.at(category);
    
    for (auto& it : m_category_indices)
    {
        if (it.second > cat_index)
        {
            it.second--;
        }
    }
    
    m_labels.erase(m_labels.begin() + cat_index);
    m_collapsed_expressions.erase(get_collapsed_expression(category));
    m_category_indices.erase(category);
    
    u64 n_labs = labs.size();
    
    for (u64 i = 0; i < n_labs; i++)
    {
        const std::string& lab = labs[i];
        
        m_label_ids.erase(lab);
        m_in_category.erase(lab);
    }
    
    m_progenitor_ids.randomize();
}

//  collapse_category: Collapse category to a single label.

void util::categorical::collapse_category(const std::string& category, bool* exists)
{
    const bool is_uniform = is_uniform_category(category, exists);
    if (!*exists || is_uniform)
    {
        return;
    }
    
    std::vector<std::string> labs;
    unchecked_in_category(labs, category);
    u64 n_labs = labs.size();
    
    std::string collapsed_expression = get_collapsed_expression(category);
    
    u32 lab_id;
    
    if (m_label_ids.contains(collapsed_expression))
    {
        lab_id = m_label_ids.at(collapsed_expression);
    }
    else
    {
        lab_id = get_next_label_id();
        unchecked_insert_label(collapsed_expression, lab_id, category);
    }
    
    for (u64 i = 0; i < n_labs; i++)
    {
        if (labs[i] != collapsed_expression)
        {
            m_label_ids.erase(labs[i]);
            m_in_category.erase(labs[i]);
        }
    }
    
    std::vector<u32>& full_labs = m_labels[m_category_indices.at(category)];
    std::fill(full_labs.begin(), full_labs.end(), lab_id);
    
    m_progenitor_ids.randomize();
}

void util::categorical::collapse_category(const std::string& category)
{
    bool dummy;
    collapse_category(category, &dummy);
}

//  empty_copy: Copy data, except id matrix

util::categorical util::categorical::empty_copy(const util::categorical& to_copy)
{
    util::categorical tmp;
    
    tmp.m_label_ids = to_copy.m_label_ids;
    tmp.m_category_indices = to_copy.m_category_indices;
    tmp.m_in_category = to_copy.m_in_category;
    tmp.m_collapsed_expressions = to_copy.m_collapsed_expressions;
    tmp.m_progenitor_ids = to_copy.m_progenitor_ids;
    
    u64 n_cats = to_copy.m_labels.size();
    
    for (u64 i = 0; i < n_cats; i++)
    {
        tmp.m_labels.push_back(std::vector<u32>());
    }
    
    return tmp;
}

//  get_next_label_id: Get the next label id.
//
//      The next label id is a random 32 bit unsigned int

util::u32 util::categorical::get_next_label_id()
{
    using util::u32;
    static std::mt19937 random_engine = std::mt19937(std::random_device()());
    
    u32 int_max = ~(u32(0));
    std::uniform_int_distribution<u32> uniform_dist(0, int_max);
    u32 id = uniform_dist(random_engine);
    
    while (has_label(id))
    {
        id = uniform_dist(random_engine);
    }
    
    return id;
}

bool util::categorical::progenitors_match(const util::categorical& other) const
{
    return m_progenitor_ids == other.m_progenitor_ids;
}

util::u32 util::categorical::get_id(const categorical* self,
                                    const categorical* other,
                                    const std::unordered_set<util::u32>& new_ids)
{
    using util::u32;
    static std::mt19937 random_engine = std::mt19937(std::random_device()());
    
    u32 int_max = ~(u32(0));
    std::uniform_int_distribution<u32> uniform_dist(0, int_max);
    u32 id = uniform_dist(random_engine);
    
    while (self->has_label(id) || other->has_label(id) || new_ids.count(id) > 0)
    {
        id = uniform_dist(random_engine);
    }
    
    return id;
}

//  get_id: Get random unsigned 32-bit integer.
//
//      Pass in a function that checks the integer to ensure
//      it is unique.

util::u32 util::get_id(std::function<bool(util::u32)> exists_func)
{
    using util::u32;
    static std::mt19937 random_engine = std::mt19937(std::random_device()());
    
    u32 int_max = ~(u32(0));
    std::uniform_int_distribution<u32> uniform_dist(0, int_max);
    u32 id = uniform_dist(random_engine);
    
    while (exists_func(id))
    {
        id = uniform_dist(random_engine);
    }
    
    return id;
}

//
//  progenitor_ids
//

util::categorical::progenitor_ids::progenitor_ids()
{
    a = 0;
    b = 0;
    randomize();
}

void util::categorical::progenitor_ids::randomize()
{
    using namespace util;
    
    auto exists_func = std::bind(&categorical::progenitor_ids::exists, this, std::placeholders::_1);
    
    a = util::get_id(exists_func);
    b = util::get_id(exists_func);
}

bool util::categorical::progenitor_ids::operator ==(const util::categorical::progenitor_ids& other) const
{
    return a == other.a && b == other.b;
}

bool util::categorical::progenitor_ids::operator !=(const util::categorical::progenitor_ids& other) const
{
    return !(util::categorical::progenitor_ids::operator ==(other));
}

bool util::categorical::progenitor_ids::exists(util::u32 id) const
{
    return a == id || b == id || id == 0;
}

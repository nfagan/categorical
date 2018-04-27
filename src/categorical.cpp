//
//  categorical.cpp
//  categorical
//
//  Created by Nick Fagan on 3/20/18.
//

#include "categorical.hpp"
#include <random>
#include <iostream>
#include <algorithm>

util::categorical::categorical()
{
    m_size = 0;
    m_next_id = 1;
}

util::categorical::~categorical()
{
    //
}

//  !=: Check for inequality.

bool util::categorical::operator !=(const util::categorical &other) const
{
    return !(util::categorical::operator ==(other));
}

//  unchecked_eq_progenitors_match: Check for equality, assuming progenitors and sizes match.

bool util::categorical::unchecked_eq_progenitors_match(const util::categorical &other, util::u64 sz) const
{
    u64 n_cats = m_labels.size();
    
    for (u64 i = 0; i < n_cats; i++)
    {
        const std::vector<u32>& own_labs = m_labels[i];
        const std::vector<u32>& other_labs = other.m_labels[i];
        
        for (u64 j = 0; j < sz; j++)
        {
            if (own_labs[j] != other_labs[j])
            {
                return false;
            }
        }
    }
    
    return true;
}

//  ==: Check for equality.

bool util::categorical::operator ==(const util::categorical &other) const
{
    using util::u64;
    using util::u32;
    
    if (this == &other)
    {
        return true;
    }
    
    u64 own_sz = size();
    u64 other_sz = other.size();
    
    if (own_sz != other_sz)
    {
        return false;
    }
    
    if (m_progenitor_ids == other.m_progenitor_ids)
    {
        return unchecked_eq_progenitors_match(other, own_sz);
    }
    
    if (m_label_ids.size() != other.m_label_ids.size())
    {
        return false;
    }
    
    if (!categories_match(other))
    {
        return false;
    }
    
    std::vector<std::string> labs = m_label_ids.keys();
    u64 n_labs = labs.size();
    
    for (u64 i = 0; i < n_labs; i++)
    {
        const std::string& lab = labs[i];
        
        if (!other.m_label_ids.contains(lab))
        {
            return false;
        }
        
        const std::string& own_cat = m_in_category.at(lab);
        const std::string& other_cat = other.m_in_category.at(lab);
        
        if (own_cat != other_cat)
        {
            return false;
        }
        
        u32 own_id = m_label_ids.at(lab);
        u32 other_id = other.m_label_ids.at(lab);
        
        u64 own_cat_index = m_category_indices.at(own_cat);
        u64 other_cat_index = other.m_category_indices.at(other_cat);
        
        const std::vector<u32>& own_labs = m_labels[own_cat_index];
        const std::vector<u32>& other_labs = other.m_labels[other_cat_index];
        
        for (u64 j = 0; j < own_sz; j++)
        {
            bool eq_own = own_labs[j] == own_id;
            bool eq_other = other_labs[j] == other_id;
            
            if (eq_own != eq_other)
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

//  has_category: True if the category is present.

bool util::categorical::has_category(const std::string &category) const
{
    return m_category_indices.find(category) != m_category_indices.end();
}

//  resize: Resize such that each column of label indices has N rows.

void util::categorical::resize(util::u64 rows)
{
    using util::u64;
    
    u64 n_labels = m_labels.size();
    
    for (u64 i = 0; i < n_labels; i++)
    {
        m_labels[i].resize(rows, 0);
    }
}

//  reserve: Resize and add / remove labels as necessary.

void util::categorical::reserve(util::u64 rows)
{
    using util::u64;
    
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
    using util::u64;
    using util::u32;
    
    u64 sz = size();
    
    if (sz == 0 || times == 0)
    {
        return;
    }
    
    u64 new_sz = sz + sz * times;
    
    resize(new_sz);
    
    u64 lab_sz = m_labels.size();
    
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

//  count: Get the number of rows associated with label.

util::u64 util::categorical::count(const std::string& lab) const
{
    using util::u32;
    using util::u64;
    
    auto lab_id_it = m_label_ids.find(lab);
    
    u64 sum = 0;
    
    if (lab_id_it == m_label_ids.endk())
    {
        return sum;
    }
    
    u32 id = lab_id_it->second;
    const std::string& in_cat = m_in_category.at(lab);
    const u64 cat_idx = m_category_indices.at(in_cat);
    
    const std::vector<u32>& lab_col = m_labels[cat_idx];
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
    util::u64 sz = size();
    
    std::vector<util::u32> new_labs(sz);
    m_category_indices[category] = n_categories();
    m_labels.push_back(new_labs);
    m_collapsed_expressions.insert(collapsed_expression);
    
    //  fill the category with the collapsed expression for the category.
    if (sz > 0)
    {
        set_collapsed_expressions(m_labels[m_labels.size()-1], category, collapsed_expression, 0);
    }
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

//  find: Get indices of labels.

std::vector<util::u64> util::categorical::find(const std::vector<std::string>& labels,
                                               util::u64 index_offset) const
{
    using util::u64;
    using util::bit_array;
    
    std::vector<util::u64> out;
    
    const u64 n_in = labels.size();
    const u64 sz = size();
    
    if (n_in == 0 || sz == 0)
    {
        return out;
    }
    
    std::unordered_map<std::string, bit_array> index_map;
    
    for (u64 i = 0; i < n_in; i++)
    {
        const std::string& lab = labels[i];
        
        auto search_it = m_label_ids.find(lab);
        
        //  label doesn't exist
        if (search_it == m_label_ids.endk())
        {
            return out;
        }
        
        u32 lab_id = search_it->second;
        const std::string& cat = m_in_category.at(lab);
        u64 cat_idx = m_category_indices.at(cat);
        
        bit_array index = util::categorical::assign_bit_array(m_labels[cat_idx], lab_id);
        
        if (index_map.find(cat) == index_map.end())
        {
            index_map[cat] = index;
        }
        else
        {
            bit_array& current = index_map[cat];
            bit_array::unchecked_dot_or(current, current, index, 0, sz);
        }
    }
    
    util::bit_array final_index(sz, true);
    
    for (const auto& it : index_map)
    {
        bit_array::unchecked_dot_and(final_index, final_index, it.second, 0, sz);
    }
    
    return bit_array::findv(final_index, index_offset);
}

//  assign_bit_array: Assign true to bit_array where label id is found

util::bit_array util::categorical::assign_bit_array(const std::vector<util::u32>& labels, util::u32 lab)
{
    util::u64 sz = labels.size();
    
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

//  find_all: Get indices of all possible unique combinations of labels.
//
//      find_all does not return the combinations.

std::vector<std::vector<util::u64>> util::categorical::find_all(const std::vector<std::string> &categories,
                                                   util::u64 index_offset) const
{
    using util::u64;
    using util::u32;
    
    std::vector<std::vector<u64>> result;
    
    u64 n_cats_in = categories.size();
    
    if (n_cats_in == 0)
    {
        return result;
    }
    
    std::vector<u32> category_inds;
    
    for (u64 i = 0; i < n_cats_in; i++)
    {
        auto category_idx_it = m_category_indices.find(categories[i]);
        
        //  if a category doesn't exist, no combinations can exist with it.
        if (category_idx_it == m_category_indices.end())
        {
            return result;
        }
        
        category_inds.push_back(category_idx_it->second);
    }
    
    size_t size_int = sizeof(u32);
    std::string hash_code(n_cats_in * size_int, 'a');
    char* hash_code_ptr = &hash_code[0];
    
    const u64 rows = size();
    
    std::unordered_map<std::string, u64> combination_exists;
    u64 next_id = 0;
    
    for (u64 i = 0; i < rows; i++)
    {
        for (u64 j = 0; j < n_cats_in; j++)
        {
            const std::vector<u32>& full_cat = m_labels[category_inds[j]];
            //  copy bits to string
            std::memcpy(hash_code_ptr + j * size_int, &full_cat[i], size_int);
        }
        
        auto c_it = combination_exists.find(hash_code);
        bool c_exists = c_it != combination_exists.end();
        u64 comb_idx;
        
        if (!c_exists)
        {
            combination_exists[hash_code] = next_id;
            
            comb_idx = next_id;
            
            next_id++;
            
            result.push_back(std::vector<u64>());
        }
        else
        {
            comb_idx = c_it->second;
        }
        
        std::vector<u64>& inds_ptr = result[comb_idx];
        inds_ptr.push_back(i + index_offset);
    }
    
    return result;
}

//  find_allc: Get indices of all possible unique combinations of labels.
//
//      find_allc also returns the combinations.

util::combinations_t util::categorical::find_allc(const std::vector<std::string>& categories,
                                                  util::u64 index_offset) const
{
    using util::u64;
    using util::u32;
    
    util::combinations_t result;
    
    u64 n_cats_in = categories.size();
    
    if (n_cats_in == 0)
    {
        return result;
    }
    
    std::vector<u32> category_inds;
    
    for (u64 i = 0; i < n_cats_in; i++)
    {
        auto category_idx_it = m_category_indices.find(categories[i]);
        
        //  if a category doesn't exist, no combinations can exist with it.
        if (category_idx_it == m_category_indices.end())
        {
            return result;
        }
        
        category_inds.push_back(category_idx_it->second);
    }
    
    size_t size_int = sizeof(u32);
    std::string hash_code(n_cats_in * size_int, 'a');
    char* hash_code_ptr = &hash_code[0];
    
    const u64 rows = size();
    
    std::unordered_map<std::string, u64> combination_exists;
    u64 next_id = 0;
    
    for (u64 i = 0; i < rows; i++)
    {
        for (u64 j = 0; j < n_cats_in; j++)
        {
            const std::vector<u32>& full_cat = m_labels[category_inds[j]];
            //  copy bits to string
            std::memcpy(hash_code_ptr + j * size_int, &full_cat[i], size_int);
        }
        
        auto c_it = combination_exists.find(hash_code);
        bool c_exists = c_it != combination_exists.end();
        u64 comb_idx;
        
        if (!c_exists)
        {
            for (u64 j = 0; j < n_cats_in; j++)
            {
                const std::vector<u32>& full_cat = m_labels[category_inds[j]];
                result.combinations.push_back(m_label_ids.at(full_cat[i]));
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
        inds_ptr.push_back(i + index_offset);
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

//  unchecked_keep_each [private]: Main utility to keep each subset.

void util::categorical::unchecked_keep_each(const std::vector<std::vector<util::u64>>& indices,
                                            util::u64 index_offset)
{
    using util::u64;
    using util::u32;
    
    util::categorical copy = *this;
    
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
    using util::u64;
    using util::u32;
    
    for (const auto& it : m_category_indices)
    {
        collapse_category(it.first);
    }
    
    if (size() <= 1)
    {
        return;
    }
    
    resize(1);
}

//  set_category: Set partial contents of a category.

util::u32 util::categorical::set_category(const std::string &category,
                                          const std::vector<std::string> &full_category,
                                          const std::vector<util::u64>& at_indices,
                                          util::s64 index_offset,
                                          bool check_bounds)
{
    using util::u64;
    using util::u32;
    using util::bit_array;
    
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
        
        u64 max = util::categorical::maximum(at_indices, n_indices);
        
        if (max + index_offset > max || max == ~(u64(0)))
        {
            return util::categorical_status::CAT_OVERFLOW;
        }
        
        reserve(max + index_offset + 1);
#else
        return util::categorical_status::WRONG_CATEGORY_SIZE;
#endif
    }
    else if (check_bounds)
    {
        u32 bounds_status = bounds_check(at_indices, n_indices, sz, index_offset);
        
        if (bounds_status != util::categorical_status::OK)
        {
            return bounds_status;
        }
    }
    
    bool randomize_on_insert = true;
    
    u64 category_idx = category_it->second;
    std::vector<u32>& labels = m_labels[category_idx];
    
    std::unordered_map<std::string, u32> processed;
    
    for (u64 i = 0; i < n_indices; i++)
    {
        const std::string& lab = is_scalar ? full_category[0] : full_category[i];
        
        u32 lab_id;
        
        if (processed.count(lab) == 0)
        {
            //  make sure label is not a collapsed expression for the wrong
            //  category
            if (m_collapsed_expressions.count(lab) > 0 &&
                get_collapsed_expression(category) != lab)
            {
                if (sz == 0)
                {
                    reserve(0);
                }
                
                return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
            }
            
            //  make sure the label is not in a different category
            if (has_label(lab))
            {
                const std::string& in_cat = m_in_category[lab];
                
                if (in_cat != category)
                {
                    return util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY;
                }
                
                lab_id = m_label_ids.at(lab);
            }
            else
            {
                lab_id = get_next_label_id();
                unchecked_insert_label(lab, lab_id, category);
                
                if (randomize_on_insert)
                {
                    m_progenitor_ids.randomize();
                    randomize_on_insert = false;
                }
            }
            
            processed[lab] = lab_id;
        }
        else
        {
            lab_id = processed[lab];
        }
        
        labels[at_indices[i] + index_offset] = lab_id;
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

util::u32 util::categorical::set_category(const std::string &category,
                                          const std::vector<std::string> &full_category)
{
    using util::u64;
    using util::u32;
    
    u64 own_size = size();
    u64 cat_sz = full_category.size();
    
    if (cat_sz == 1 && own_size > 0)
    {
        return fill_category(category, full_category[0]);
    }
    
    auto category_it = m_category_indices.find(category);
    
    if (category_it == m_category_indices.end())
    {
        return util::categorical_status::CATEGORY_DOES_NOT_EXIST;
    }
    
    u64 category_idx = category_it->second;
    
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
    
    bool randomize_on_insert = true;
    
    std::vector<u32>& labels = m_labels[category_idx];
    
    std::unordered_map<std::string, u32> processed;
    
    auto copy_ids = m_label_ids;
    
    for (u64 i = 0; i < cat_sz; i++)
    {
        const std::string& lab = full_category[i];
        
        u32 lab_id;
        
        if (processed.count(lab) == 0)
        {
            //  make sure label is not a collapsed expression for the wrong
            //  category
            if (m_collapsed_expressions.count(lab) > 0 &&
                get_collapsed_expression(category) != lab)
            {
                if (own_size == 0)
                {
                    reserve(0);
                }
                
                return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
            }
            
            //  make sure the label is not in a different category
            if (has_label(lab))
            {
                const std::string& in_cat = m_in_category[lab];
                
                if (in_cat != category)
                {
                    return util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY;
                }
                
                lab_id = m_label_ids.at(lab);
                
                copy_ids.erase(lab);
            }
            else
            {
                lab_id = get_next_label_id();
                unchecked_insert_label(lab, lab_id, category);
                
                if (randomize_on_insert)
                {
                    m_progenitor_ids.randomize();
                    randomize_on_insert = false;
                }
            }
            
            processed[lab] = lab_id;
        }
        else
        {
            lab_id = processed[lab];
        }
        
        labels[i] = lab_id;
    }
    
    std::vector<std::string> to_erase = copy_ids.keys();
    
    for (const auto& it : to_erase)
    {
        if (m_in_category.at(it) == category)
        {
            m_label_ids.erase(it);
            m_in_category.erase(it);
        }
    }
    
    return util::categorical_status::OK;
}

//  fill_category: Fill category with single label.

util::u32 util::categorical::fill_category(const std::string &category, const std::string &lab)
{
    using util::u64;
    using util::u32;
    
    auto category_it = m_category_indices.find(category);
    
    if (category_it == m_category_indices.end())
    {
        return util::categorical_status::CATEGORY_DOES_NOT_EXIST;
    }
    
    u64 sz = size();
    
    //  filling category when size is 0 has no effect.
    if (sz == 0)
    {
        return util::categorical_status::OK;
    }
    
    if (m_collapsed_expressions.count(lab) > 0 &&
        get_collapsed_expression(category) != lab)
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
        
        bool should_erase = exists ? c_lab != lab : true;
        
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
    
    auto other_end = other.m_category_indices.end();
    
    for (const auto& it : m_category_indices)
    {
        auto other_it = other.m_category_indices.find(it.first);
        
        if (other_it == other_end)
        {
            return false;
        }
    }
    
    return true;
}

//  replace_labels: Replace label with single label.

util::u32 util::categorical::replace_labels(const std::string& from, const std::string& with)
{
    std::vector<std::string> input = { from };
    return replace_labels(input, with);
}

//  replace_labels: Replace labels with single label.

util::u32 util::categorical::replace_labels(const std::vector<std::string>& from, const std::string& with)
{
    using util::u64;
    
    u64 n_from = from.size();
    
    if (n_from == 0)
    {
        return util::categorical_status::OK;
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
    
    if (m_collapsed_expressions.count(with) > 0)
    {
        if (with != get_collapsed_expression(last_cat))
        {
            return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
        }
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

util::u32 util::categorical::keep(std::vector<util::u64>& at_indices, util::s64 offset)
{
    using util::u64;
    using util::u32;
    
    u64 n_indices = at_indices.size();
    u64 sz = size();

    u64 n_cats = m_labels.size();
    
    std::vector<std::vector<u32>> tmp(n_cats);
    
    for (u64 i = 0; i < n_cats; i++)
    {
        std::vector<u32>& tmp_col = tmp[i];
        std::vector<u32>& own_col = m_labels[i];
        
        tmp_col.resize(n_indices);
        
        for (u64 j = 0; j < n_indices; j++)
        {
            u64 idx = at_indices[j] + offset;
            
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

//  empty: Retain 0 rows, and prune missing labels.

void util::categorical::empty()
{
    reserve(0);
}

//  prune: Remove labels wihout rows.

util::u64 util::categorical::prune()
{
    using util::u64;
    using util::u32;
    
    u64 n_cats = m_labels.size();
    
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
        u32 id = remaining[i];
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

//  append: Append one categorical object to another.

util::u32 util::categorical::append(const util::categorical &other)
{
    using util::u32;
    using util::u64;
    
    u64 other_sz = other.size();
    u64 own_sz = size();
    
    if (other_sz == 0)
    {
        return util::categorical_status::OK;
    }
    
    if (own_sz == 0)
    {
        *this = other;
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
        unchecked_append_progenitors_match(other, own_sz, other_sz);
        return util::categorical_status::OK;
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
    
    append_fill_new_label_ids(other, replace_other_labs, own_sz, other_sz);
    
    return util::categorical_status::OK;
}

void util::categorical::append_fill_new_label_ids(const util::categorical& other,
                               const std::unordered_map<util::u32, util::u32>& replace_other_labs,
                               util::u64 own_sz,
                               util::u64 other_sz)
{
    size_t n_copy = other_sz * sizeof(util::u32);
    
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
                                        util::s64 index_offset)
{
    using util::u32;
    using util::u64;
    
    u64 n_cols = m_labels.size();
    u64 n_indices = to_indices.size();
    
    for (u64 i = 0; i < n_cols; i++)
    {
        std::vector<u32>& own_labs = m_labels[i];
        const std::vector<u32>& other_labs = other.m_labels[i];
        
        for (u64 j = 0; j < n_indices; j++)
        {
            u64 to_idx = to_indices[j] + index_offset;
            own_labs[to_idx] = other_labs[j];
        }
    }
}

//  unchecked_assign_progenitors_match: Assign contents at indices, assuming progenitors match.

void util::categorical::unchecked_assign_progenitors_match(const util::categorical &other,
                                                           const std::vector<util::u64> &to_indices,
                                                           const std::vector<util::u64> &from_indices,
                                                           util::s64 index_offset)
{
    using util::u32;
    using util::u64;
    
    u64 n_cols = m_labels.size();
    u64 n_indices = to_indices.size();
    
    for (u64 i = 0; i < n_cols; i++)
    {
        std::vector<u32>& own_labs = m_labels[i];
        const std::vector<u32>& other_labs = other.m_labels[i];
        
        for (u64 j = 0; j < n_indices; j++)
        {
            u64 from_idx = from_indices[j] + index_offset;
            u64 to_idx = to_indices[j] + index_offset;
            own_labs[to_idx] = other_labs[from_idx];
        }
    }
}

//  assign: Assign contents at indices.

util::u32 util::categorical::assign(const util::categorical& other,
                                    const std::vector<util::u64>& at_indices,
                                    util::s64 index_offset)
{
    using util::u32;
    using util::u64;
    
    if (!categories_match(other))
    {
        return util::categorical_status::CATEGORIES_DO_NOT_MATCH;
    }
    
    u64 n_indices = at_indices.size();
    u64 own_sz = size();
    u64 other_sz = other.size();
    
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
    
    u32 bounds_status = util::categorical::bounds_check(at_indices, n_indices, own_sz, index_offset);
    
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
            const u64 own_idx = at_indices[i] + index_offset;
            
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
                                    util::s64 index_offset)
{
    using util::u32;
    using util::u64;
    
    if (!categories_match(other))
    {
        return util::categorical_status::CATEGORIES_DO_NOT_MATCH;
    }
    
    u64 n_to_indices = to_indices.size();
    u64 n_from_indices = from_indices.size();
    u64 own_sz = size();
    u64 other_sz = other.size();
    
    //  error if n from indices does not match n to indices
    if (n_to_indices != n_from_indices)
    {
        return util::categorical_status::WRONG_INDEX_SIZE;
    }
    
    //  bounds check
    u32 own_status = util::categorical::bounds_check(to_indices, n_to_indices, own_sz, index_offset);
    u32 other_status = util::categorical::bounds_check(from_indices, n_from_indices, other_sz, index_offset);
    u32 ok = util::categorical_status::OK;
    
    if (own_status != ok || other_status != ok)
    {
        return own_status;
    }
    
    if (m_progenitor_ids == other.m_progenitor_ids)
    {
        unchecked_assign_progenitors_match(other, to_indices, from_indices, index_offset);
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
            const u64 from_idx = from_indices[i] + index_offset;
            const u64 to_idx = to_indices[i] + index_offset;
            
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

//  merge: Merge array contents.

util::u32 util::categorical::merge(const util::categorical& other)
{
    using util::u64;
    using util::u32;
    
    u64 own_sz = size();
    u64 other_sz = other.size();
    
    bool is_scalar = other_sz == 1;
    bool sizes_match = own_sz == other_sz;
    
    if (!sizes_match && !is_scalar)
    {
        return util::categorical_status::INCOMPATIBLE_SIZES;
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
    
    util::u32 require_cat_status = merge_require_categories(other);
    
    if (require_cat_status != util::categorical_status::OK)
    {
        return require_cat_status;
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
    
    merge_fill_new_label_ids(other, replace_other_labs, is_scalar, sizes_match, own_sz);
    
    return util::categorical_status::OK;
}

void util::categorical::merge_fill_new_label_ids(const util::categorical& other,
                                                 std::unordered_map<util::u32, util::u32>& replace_other_labs,
                                                 bool is_scalar,
                                                 bool sizes_match,
                                                 util::u64 own_sz)
{
    for (const auto& cats : other.m_category_indices)
    {
        u64 own_idx = m_category_indices.at(cats.first);
        u64 other_idx = cats.second;
        
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

util::u32 util::categorical::merge_check_collapsed_expressions(const util::categorical &other) const
{
    for (const auto& it : m_category_indices)
    {
        const std::string& cat = it.first;
        
        std::string collapsed_expression = get_collapsed_expression(cat);
        
        if (other.has_label(collapsed_expression) && other.m_in_category.at(collapsed_expression) != cat)
        {
            return util::categorical_status::COLLAPSED_EXPRESSION_IN_WRONG_CATEGORY;
        }
    }
    
    return util::categorical_status::OK;
}

util::u32 util::categorical::merge_require_categories(const util::categorical& other)
{
    std::vector<std::string> new_categories;
    
    for (const auto& it : other.m_category_indices)
    {
        const std::string& cat = it.first;
        
        if (!has_category(cat))
        {
            new_categories.push_back(cat);
        }
        
        util::u32 cat_status = require_category(cat);
        
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
                                                     std::unordered_map<util::u32, util::u32>& replace_other) const
{
    std::unordered_set<util::u32> new_label_ids;
    
    std::vector<std::string> other_labs = other.m_label_ids.keys();
    
    auto own_lab_it_end = m_label_ids.endk();
    
    u64 n_other_labs = other_labs.size();
    
    for (u64 i = 0; i < n_other_labs; i++)
    {
        const std::string& other_lab = other_labs[i];
        const std::string& other_in_cat = other.m_in_category.at(other_lab);
        
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
//                util::u32 replace_id = util::categorical::get_id(this, &other, new_label_ids);
//                new_label_ids.insert(replace_id);
//                replace_other[other_id] = replace_id;
//                tmp_label_ids.insert(other_lab, replace_id);
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

//  bounds_check: Ensure indices are in bounds.

util::u32 util::categorical::bounds_check(const std::vector<util::u64>& indices,
                       util::u64 n_check,
                       util::u64 end,
                       util::u64 index_offset)
{
    using util::u64;
    
    for (u64 i = 0; i < n_check; i++)
    {
        if (indices[i] + index_offset >= end)
        {
            return util::categorical_status::OUT_OF_BOUNDS;
        }
    }
    
    return util::categorical_status::OK;
}

//  maximum: Get the largest element in a vector of indices.

util::u64 util::categorical::maximum(const std::vector<util::u64> &indices, util::u64 end)
{
    util::u64 max = 0;
    
    for (util::u64 i = 0; i < end; i++)
    {
        if (indices[i] > max)
        {
            max = indices[i];
        }
    }
    
    return max;
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
    
    std::sort(cats.begin(), cats.end());
    
    return cats;
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
    std::vector<std::string> cats = get_categories();
    
    std::vector<const std::vector<util::u32>*> res(cats.size());
    
    util::u64 out_idx = 0;
    
    for (const auto& cat : cats)
    {
        util::u64 cat_idx = m_category_indices.at(cat);
        res[out_idx++] = &m_labels[cat_idx];
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
                                                             util::s64 index_offset) const
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
        u64 idx = at_indices[i] + index_offset;
        
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

std::vector<std::string> util::categorical::in_category(const std::string &category) const
{
    std::vector<std::string> result;
    unchecked_in_category(result, category);
    return result;
}

std::vector<std::string> util::categorical::in_categories(const std::vector<std::string> &categories,
                                                          bool *exist) const
{
    std::vector<std::string> result;
    
    for (const auto& cat : categories)
    {
        if (!has_category(cat))
        {
            *exist = false;
            return result;
        }
    }
    
    *exist = true;
    
    std::vector<std::string> labs = m_label_ids.keys();
    util::u64 n_labs = labs.size();
    util::u64 n_cats = categories.size();
    
    for (util::u64 i = 0; i < n_labs; i++)
    {
        const std::string& lab = labs[i];
        const std::string& cat = m_in_category.at(lab);
        
        for (util::u64 j = 0; j < n_cats; j++)
        {
            if (cat == categories[j])
            {
                result.push_back(lab);
            }
        }
    }
    
    return result;
}

void util::categorical::unchecked_in_category(std::vector<std::string> &out, const std::string &category) const
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

void util::categorical::remove_category(const std::string &category, bool *exists)
{
    using util::u32;
    using util::u64;
    
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
    using util::u32;
    
    std::vector<std::string> labs = in_category(category, exists);
    u64 n_labs = labs.size();
    
    if (!(*exists) || n_labs <= 1)
    {
        return;
    }
    
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

//  get_next_label_id: Get the next label id.
//
//      The next label id is either m_next_id + 1, or a random
//      32-bit unsigned integer, if m_next_id is at integer capacity.

util::u32 util::categorical::get_next_label_id()
{
    static std::mt19937 random_engine = std::mt19937(std::random_device()());
    
    using util::u32;
    
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

util::u32 util::categorical::get_id(const categorical* self, const categorical* other,
                   const std::unordered_set<util::u32>& new_ids)
{
    static std::mt19937 random_engine = std::mt19937(std::random_device()());
    
    using util::u32;
    
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
    static std::mt19937 random_engine = std::mt19937(std::random_device()());
    
    using util::u32;
    
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

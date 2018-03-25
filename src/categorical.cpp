//
//  categorical.cpp
//  categorical
//
//  Created by Nick Fagan on 3/20/18.
//

#include "categorical.hpp"
#include <random>
#include <iostream>

util::categorical::categorical()
{
    m_size = 0;
    m_next_id = 1;
}

util::categorical::~categorical()
{
    //
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
    u64 orig_size = size();
    
    for (u64 i = 0; i < n_labels; i++)
    {
        m_labels[i].resize(rows, 0);
    }
    
    if (orig_size == 0)
    {
        set_all_collapsed_expressions();
    }
    
    if (rows < orig_size)
    {
        prune();
    }
}

void util::categorical::reserve(util::u64 rows)
{
    using util::u64;
    
    u64 n_labels = m_labels.size();
    u64 orig_size = size();
    
    for (u64 i = 0; i < n_labels; i++)
    {
        m_labels[i].resize(rows);
    }
    
    if (rows < orig_size)
    {
        prune();
    }
    else
    {
        set_all_collapsed_expressions(orig_size);
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

//  add_category: Add a new category.
//
//      An error code is returned if the category already exists.

util::u32 util::categorical::add_category(const std::string& category)
{
    if (has_category(category))
    {
        return categorical_status::CATEGORY_EXISTS;
    }
    
    unchecked_add_category(category, get_collapsed_expression(category));
    
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
    
    m_category_indices[category] = n_categories();
    m_labels.push_back(std::vector<util::u32>(sz));
    m_collapsed_expressions.insert(collapsed_expression);
    
    //  fill the category with the collapsed expression for the category.
    if (sz > 0)
    {
        std::vector<util::u32>& labs = m_labels[m_labels.size()-1];
        set_collapsed_expressions(labs, category, collapsed_expression);
    }
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
        util::u32 id = get_next_label_id();
        m_label_ids.insert(collapsed_expression, id);
    }
    
    m_in_category[collapsed_expression] = category;
    
    std::fill(labs.begin() + start_offset, labs.end(), id);
}

//  set_all_collapsed_expressions: Initialize all categories with collapsed expressions.

void util::categorical::set_all_collapsed_expressions(util::u64 start_offset)
{
    for (const auto& it : m_category_indices)
    {
        const util::u64 cat_idx = it.second;
        const std::string& cat = it.first;
        
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

//  set_category: Set partial contents of a category.

util::u32 util::categorical::set_category(const std::string &category,
                                          const std::vector<std::string> &full_category,
                                          const util::bit_array& at_indices)
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
    const u64 index_sz = at_indices.size();
    const u64 n_indices = at_indices.sum();
    
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
    
    if (sz > 0 && index_sz != sz)
    {
        return util::categorical_status::WRONG_INDEX_SIZE;
    }
    
    u64 category_idx = category_it->second;
    std::vector<u32>& labels = m_labels[category_idx];
    
    const std::vector<u64> indices = bit_array::findv(at_indices);
    
    if (sz == 0)
    {
        resize(index_sz);
    }
    
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
                    resize(0);
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
                
                m_in_category[lab] = category;
                m_label_ids.insert(lab, lab_id);
            }
            
            processed[lab] = lab_id;
        }
        else
        {
            lab_id = processed[lab];
        }
        
        labels[indices[i]] = lab_id;
    }
    
    prune();
    
    return util::categorical_status::OK;
    
}

//  set_category: Set full contents of a category.
//
//      If the object is of size 0, the incoming category can be of any size. Otherwise,
//      it must match the current size of the object.

util::u32 util::categorical::set_category(const std::string &category,
                                          const std::vector<std::string> &full_category)
{
    using util::u64;
    using util::u32;
    
    auto category_it = m_category_indices.find(category);
    
    if (category_it == m_category_indices.end())
    {
        return util::categorical_status::CATEGORY_DOES_NOT_EXIST;
    }
    
    u64 category_idx = category_it->second;
    
    std::vector<u32>& labels = m_labels[category_idx];
    
    u64 own_size = size();
    u64 cat_sz = full_category.size();
    
    if (own_size > 0 && cat_sz != own_size)
    {
        return util::categorical_status::WRONG_CATEGORY_SIZE;
    }
    
    if (own_size == 0)
    {
        resize(cat_sz);
    }
    
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
                    resize(0);
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
                
                m_in_category[lab] = category;
                m_label_ids.insert(lab, lab_id);
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

//  get_collapsed_expression: Get the string representation of a collapsed category.

std::string util::categorical::get_collapsed_expression(const std::string &for_cat) const
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
    
    if (n_indices == 0)
    {
        empty();
        return util::categorical_status::OK;
    }
    
    std::sort(at_indices.begin(), at_indices.end());
    
    if (at_indices[n_indices-1] + offset >= sz)
    {
        return util::categorical_status::OUT_OF_BOUNDS;
    }

    u64 n_cats = m_labels.size();
    
    std::vector<std::vector<u32>> tmp(n_cats);
    
    for (u64 i = 0; i < n_cats; i++)
    {
        std::vector<u32>& tmp_col = tmp[i];
        std::vector<u32>& own_col = m_labels[i];
        
        tmp_col.resize(n_indices);
        
        for (u64 j = 0; j < n_indices; j++)
        {
            tmp_col[j] = own_col[at_indices[j] + offset];
        }
    }
    
    m_labels = std::move(tmp);
    
    prune();
    
    return util::categorical_status::OK;
}

//  empty: Retain 0 rows.

void util::categorical::empty()
{
    resize(0);
    prune();
}

//  prune: Remove labels wihout rows.

void util::categorical::prune()
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
}

//  append: Append one categorical object to another.

util::u32 util::categorical::append(const util::categorical &other)
{
    using util::u32;
    using util::u64;
    
    if (!categories_match(other))
    {
        return util::categorical_status::CATEGORIES_DO_NOT_MATCH;
    }
    
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
    
    u64 int_max = ~(u64(0));
    
    if (int_max - own_sz < other_sz)
    {
        return util::categorical_status::CAT_OVERFLOW;
    }
    
    std::vector<std::string> own_labels = m_label_ids.keys();
    std::vector<std::string> other_labels = other.m_label_ids.keys();
    
    auto copy_other_label_ids = other.m_label_ids;
    
    std::unordered_map<u32, u32> replace_own_label_ids;
    std::unordered_map<u32, u32> replace_other_label_ids;
    std::unordered_set<u32> new_label_ids;
    
    u64 own_n_labs = own_labels.size();
    
    for (u64 i = 0; i < own_n_labs; i++)
    {
        const std::string& lab = own_labels[i];
        const u32 own_lab_id = m_label_ids.at(lab);
        
        auto other_lab_it = copy_other_label_ids.find(lab);
        bool make_new_lab = false;
        
        //  other has this label
        if (other_lab_it != copy_other_label_ids.endk())
        {
            u32 other_lab_id = other_lab_it->second;
            
            if (m_in_category.at(lab) != other.m_in_category.at(lab))
            {
                return util::categorical_status::LABEL_EXISTS_IN_OTHER_CATEGORY;
            }
            
            make_new_lab = other_lab_id != own_lab_id;
            
            //  ... but the label is bound to different id
            if (make_new_lab)
            {
                replace_other_label_ids[other_lab_id] = own_lab_id;
                make_new_lab = other.m_label_ids.contains(own_lab_id);
            }
            
            copy_other_label_ids.erase(lab);
        }
        
        if (make_new_lab)
        {
            u32 new_id = util::categorical::get_id(this, &other, new_label_ids);
            replace_other_label_ids[own_lab_id] = new_id;
            new_label_ids.insert(new_id);
        }
    }
    
    std::vector<std::string> new_labels = copy_other_label_ids.keys();
    u64 n_new_labels = new_labels.size();
    
    for (u64 i = 0; i < n_new_labels; i++)
    {
        const std::string& new_lab = new_labels[i];
        
        u32 new_lab_id = copy_other_label_ids.at(new_lab);
        
        auto replace_other_lab_it = replace_other_label_ids.find(new_lab_id);
        
        //  this is a label id marked for replacement
        if (replace_other_lab_it != replace_other_label_ids.end())
        {
            new_lab_id = replace_other_lab_it->second;
        }
        //  swap the incoming id with a new one
        else if (m_label_ids.contains(new_lab_id))
        {
            const std::string& c_lab = m_label_ids.at(new_lab_id);
            u32 new_id = util::categorical::get_id(this, &other, new_label_ids);
            
            //  mark that we must replace this id
            replace_own_label_ids[new_lab_id] = new_id;
            m_label_ids.insert(c_lab, new_id);
            
            new_label_ids.insert(new_id);
        }
        
        m_label_ids.insert(new_lab, new_lab_id);
        
        m_in_category[new_lab] = other.m_in_category.at(new_lab);
    }
    
    u64 new_sz = own_sz + other_sz;
    
    resize(new_sz);
    
    //  copy other elements to appropriate "column"
    size_t n_copy = other_sz * sizeof(u32);
    
    for (const auto& it : m_category_indices)
    {
        u64 own_index = it.second;
        u64 other_index = other.m_category_indices.at(it.first);
        
        u32* dest = m_labels[own_index].data();
        const u32* src = other.m_labels[other_index].data();
        
        std::memcpy(dest + own_sz, src, n_copy);
    }
    
    util::categorical::replace_labels(m_labels, 0, own_sz, replace_own_label_ids);
    util::categorical::replace_labels(m_labels, own_sz, new_sz, replace_other_label_ids);
    
    return util::categorical_status::OK;
    
}

//  replace_labels: Helper function to replace outgoing label ids with new ids.

void util::categorical::replace_labels(std::vector<std::vector<u32>>& labels,
                                       util::u64 start, util::u64 stop,
                                       const std::unordered_map<util::u32, util::u32>& replace_map)
{
    using util::u64;
    
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

//  get_categories: Get all string categories.

std::vector<std::string> util::categorical::get_categories() const
{
    std::vector<std::string> cats(n_categories());
    
    util::u64 i = 0;
    
    for (const auto& it : m_category_indices)
    {
        cats[i++] = it.first;
    }
    
    return cats;
}

//  get_labels: Get all string labels.

std::vector<std::string> util::categorical::get_labels() const
{
    return m_label_ids.keys();
}

//  full_category: Replace int label ids with string labels.

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

//  in_category: Get all labels in a category.
std::vector<std::string> util::categorical::in_category(const std::string& category, bool* exists) const
{
    std::vector<std::string> result;
    
    if (!has_category(category))
    {
        *exists = false;
        return result;
    }
    
    *exists = true;
    
    std::vector<std::string> labs = m_label_ids.keys();
    util::u64 n_labs = labs.size();
    
    for (util::u64 i = 0; i < n_labs; i++)
    {
        const std::string& lab = labs[i];
        
        if (m_in_category.at(lab) == category)
        {
            result.push_back(lab);
        }
    }
    
    return result;
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
    
    if (m_next_id < int_max)
    {
        return m_next_id++;
    }
    
    std::uniform_int_distribution<u32> uniform_dist(0, int_max);
    
    u32 id = uniform_dist(random_engine);
    
    while (has_label(id))
    {
        id = uniform_dist(random_engine);
    }
    
    return id;
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

//
//  set_membership.hpp
//  categorical
//
//  Created by Nick Fagan on 10/18/19.
//

#pragma once

#include "types.hpp"
#include <vector>
#include <unordered_map>

namespace util
{
    struct VisitedRow;
    class categorical;
    class set_union;
    class set_unique;
}

class util::set_unique
{
public:
    set_unique(const util::categorical& a);
    ~set_unique() = default;
    
    util::categorical operator()() const;
    util::categorical operator()(const std::vector<util::u64>& indices,
                                 util::u32* status,
                                 const util::u64 index_offset = 0) const;
private:
    const util::categorical& a;
    
private:
    util::categorical unique_impl(const std::vector<util::u64>& indices,
                                  const bool use_indices,
                                  const util::u64 index_offset,
                                  util::u32* status) const;
};

class util::set_union
{
public:
    set_union(const util::categorical& a, const util::categorical& b);
    ~set_union() = default;
    
    util::categorical make_combined(util::u32* status) const;
    util::categorical make_combined(const std::vector<util::u64>& mask_a,
                                    const std::vector<util::u64>& mask_b,
                                    util::u32* status,
                                    const util::u64 index_offset = 0) const;
    
    util::categorical make_union(util::u32* status) const;
    util::categorical make_union(const std::vector<util::u64>& mask_a,
                                 const std::vector<util::u64>& mask_b,
                                 util::u32* status,
                                 const util::u64 index_offset = 0) const;
    
    util::categorical make_union(const std::vector<std::string>& categories, util::u32* status) const;
    util::categorical make_union(const std::vector<std::string>& categories,
                                 const std::vector<util::u64>& mask_a,
                                 const std::vector<util::u64>& mask_b,
                                 util::u32* status,
                                 const util::u64 index_offset = 0) const;
    
private:
    const util::categorical& a;
    const util::categorical& b;
    
private:
    util::categorical set_combination_impl(util::u32* status,
                                           const std::vector<util::u64>& mask_a,
                                           const std::vector<util::u64>& mask_b,
                                           const util::u64 index_offset,
                                           const bool use_indices) const;
    
    util::categorical set_union_impl_matching_categories(util::u32* status,
                                                         const std::vector<std::string>& categories,
                                                         const std::vector<util::u64>& mask_a,
                                                         const std::vector<util::u64>& mask_b,
                                                         const util::u64 index_offset,
                                                         const bool use_indices) const;
    
    util::categorical set_union_impl(util::u32* status,
                                     const std::vector<std::string>& categories,
                                     const std::vector<util::u64>& mask_a,
                                     const std::vector<util::u64>& mask_b,
                                     const util::u64 index_offset,
                                     const bool use_indices) const;
    
    static bool build_union_row_hash(const util::categorical& a,
                                     const util::categorical& b,
                                     const std::vector<std::vector<u32>>& a_label_matrix,
                                     char* row_hash_ptr,
                                     const util::u64 row,
                                     const std::vector<util::u64>& category_indices);
    
    static void append_unique_rows_progenitors_match(std::vector<std::vector<util::u32>>& ids_a,
                                                     std::unordered_map<std::string, util::VisitedRow>& visited_rows_a,
                                                     const std::vector<std::vector<util::u32>>& ids_b,
                                                     const std::vector<util::u64>& indices,
                                                     const bool use_indices,
                                                     const util::u64 index_offset,
                                                     util::u32* status);
    
    static void append_unique_rows(util::categorical& a,
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
                                   util::u32* status);
    
    static std::vector<std::string> get_uniform_category_labels(const util::categorical& a,
                                                                const std::vector<std::string>& categories,
                                                                const std::vector<util::u64>& indices,
                                                                const bool use_indices,
                                                                const util::u64 index_offset,
                                                                util::u32* status);
};

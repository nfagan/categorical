//
//  set_membership.hpp
//  categorical
//
//  Created by Nick Fagan on 10/18/19.
//

#pragma once

#include "types.hpp"
#include <vector>
#include <unordered_set>
#include <unordered_map>

namespace util
{
    struct VisitedRow;
    class categorical;
    class set_union;
    class set_unique;
    
    namespace set_membership
    {
        class base;
        struct options;
    }
}

struct util::set_membership::options
{
    options() : output_indices(false), index_offset(0)
    {
        //
    }
    
    bool output_indices;
    util::u64 index_offset;
};

class util::set_membership::base
{
protected:
    base() : options()
    {
        //
    }
    
    base(const set_membership::options& opts) : options(opts)
    {
        //
    }
    
    const set_membership::options options;
};

class util::set_unique : public util::set_membership::base
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

class util::set_union : public util::set_membership::base
{
public:
    set_union(const util::categorical& a, const util::categorical& b, const set_membership::options& opts);
    ~set_union() = default;
    
    util::categorical make_combined(util::u32* status) const;
    util::categorical make_combined(const std::vector<util::u64>& mask_a,
                                    const std::vector<util::u64>& mask_b,
                                    util::u32* status) const;
    
    util::categorical make_union(util::u32* status) const;
    util::categorical make_union(const std::vector<util::u64>& mask_a,
                                 const std::vector<util::u64>& mask_b,
                                 util::u32* status) const;
    
    util::categorical make_union(const std::vector<std::string>& categories, util::u32* status) const;
    util::categorical make_union(const std::vector<std::string>& categories,
                                 const std::vector<util::u64>& mask_a,
                                 const std::vector<util::u64>& mask_b,
                                 util::u32* status) const;
    
private:
    const util::categorical& a;
    const util::categorical& b;
    
private:
    util::categorical set_combination_impl(util::u32* status,
                                           const std::vector<std::string>& cats_final,
                                           const std::vector<std::string>& cats_compute_union,
                                           const std::vector<util::u64>& mask_a,
                                           const std::vector<util::u64>& mask_b,
                                           const bool use_indices) const;
    
    util::categorical set_union_impl_matching_categories(util::u32* status,
                                                         const std::vector<std::string>& categories,
                                                         const std::vector<util::u64>& mask_a,
                                                         const std::vector<util::u64>& mask_b,
                                                         const bool use_indices) const;
    
    util::categorical set_union_impl(util::u32* status,
                                     const std::vector<std::string>& categories,
                                     const std::vector<util::u64>& mask_a,
                                     const std::vector<util::u64>& mask_b,
                                     const bool use_indices) const;
    
    static bool build_row_hash(const util::categorical& a,
                                     const util::categorical& b,
                                     const std::vector<std::vector<u32>>& a_label_matrix,
                                     char* row_hash_ptr,
                                     const util::u64 row,
                                     const std::vector<util::u64>& src_category_indices,
                                     const std::vector<util::u64>& dest_category_indices);
    
    std::vector<std::vector<util::u32>> unique_rows_to_combine(std::unordered_set<std::string>& visited_complete_rows,
                                                               std::unordered_map<std::string, util::VisitedRow>& visited_shared_rows,
                                                               const std::vector<std::vector<util::u32>>& ids,
                                                               const std::vector<util::u64>& category_indices,
                                                               const std::vector<util::u64>& shared_category_indices,
                                                               const std::vector<util::u64>& unique_category_indices,
                                                               const std::vector<util::u64>& indices,
                                                               const bool use_indices,
                                                               util::u32* status) const;
    
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

//
//  set_membership.hpp
//  categorical
//
//  Created by Nick Fagan on 10/18/19.
//

#pragma once

#include "types.hpp"
#include <vector>

namespace util
{
    class categorical;
    class set_union;
}

class util::set_union
{
public:
    set_union(const util::categorical& a, const util::categorical& b);
    ~set_union() = default;
    
    util::categorical operator()(util::u32* status);
    util::categorical operator()(const std::vector<util::u64>& mask_a,
                                 const std::vector<util::u64>& mask_b,
                                 util::u32* status,
                                 const util::u64 index_offset = 0);
private:
    const util::categorical& a;
    const util::categorical& b;
    
private:
    util::categorical set_union_impl(util::u32* status,
                                     const std::vector<util::u64>& mask_a,
                                     const std::vector<util::u64>& mask_b,
                                     const util::u64 index_offset,
                                     const bool use_indices);
    
    static bool build_union_row_hash(const util::categorical& a,
                                     const util::categorical& b,
                                     const std::vector<std::vector<u32>>& a_label_matrix,
                                     char* row_hash_ptr,
                                     const util::u64 row,
                                     const std::vector<util::u64>& category_indices);
    
    static std::vector<std::string> get_uniform_category_labels(const util::categorical& a,
                                                                const std::vector<std::string>& categories,
                                                                const std::vector<util::u64>& indices,
                                                                const bool use_indices,
                                                                const util::u64 index_offset,
                                                                util::u32* status);
};

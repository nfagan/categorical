//
//  helpers.hpp
//  categorical
//
//  Created by Nick Fagan on 10/18/19.
//

#pragma once

#include "types.hpp"
#include <vector>
#include <string>

namespace util
{
    inline void build_row_hash(char* ptr, const std::vector<std::vector<util::u32>>& id_matrix, const util::u64 row, const util::u64 num_cols)
    {
        for (util::u64 i = 0; i < num_cols; i++)
        {
            std::memcpy(ptr + i*sizeof(util::u32), &id_matrix[i][row], sizeof(util::u32));
        }
    }

    inline void build_row_hash(char* ptr,
                               const std::vector<std::vector<util::u32>>& id_matrix,
                               const util::u64 row,
                               const std::vector<util::u64>& col_indices)
    {
        const util::u64 num_cols = col_indices.size();
        for (util::u64 i = 0; i < num_cols; i++)
        {
            std::memcpy(ptr + i*sizeof(util::u32), &id_matrix[col_indices[i]][row], sizeof(util::u32));
        }
    }
    
    inline std::string make_label_id_hash_string(const util::u64 num_categories)
    {
        return std::string(num_categories * sizeof(util::u32), 'a');
    }
}

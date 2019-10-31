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
    struct VisitedRow
    {
        VisitedRow() = default;
        ~VisitedRow() = default;
        
        VisitedRow(util::u64 index_in_unique_matrix, util::u64 index_in_source_matrix) :
        index_in_unique_matrix(index_in_unique_matrix),
        index_in_source_matrix(index_in_source_matrix)
        {
            //
        }
        
        std::vector<util::s64> remaining_ids;
        util::u64 index_in_unique_matrix;
        util::u64 index_in_source_matrix;
    };
    
    template <typename T>
    inline util::u64 num_rows_in_matrix(const std::vector<std::vector<T>>& v)
    {
        return v.empty() ? 0 : v[0].size();
    }
    
    template <typename T>
    inline void add_column(std::vector<std::vector<T>>& v)
    {
        const u64 num_rows = num_rows_in_matrix(v);
        std::vector<T> empty_col(num_rows);
        v.emplace_back(std::move(empty_col));
    }
    
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
    
    inline void build_row_hash(char* ptr,
                               const std::vector<std::vector<util::u32>>& id_matrix,
                               const util::u64 row,
                               const std::vector<util::u64>& src_col_indices,
                               const std::vector<util::u64>& dest_col_indices)
    {
        const util::u64 num_cols = src_col_indices.size();
        for (util::u64 i = 0; i < num_cols; i++)
        {
            std::memcpy(ptr + dest_col_indices[i]*sizeof(util::u32), &id_matrix[src_col_indices[i]][row], sizeof(util::u32));
        }
    }
    
    inline std::string make_label_id_hash_string(const util::u64 num_categories)
    {
        return std::string(num_categories * sizeof(util::u32), 'a');
    }
}

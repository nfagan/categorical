#pragma once

#include <cstdint>

namespace util {
    namespace ops {
        static constexpr uint32_t CREATE = 0u;
        static constexpr uint32_t SET_CATEGORY = 1u;
        static constexpr uint32_t FIND_ALLC = 2u;
        static constexpr uint32_t REQUIRE_CATEGORY = 3u;
        static constexpr uint32_t DESTROY = 4u;
        static constexpr uint32_t SIZE = 5u;
        static constexpr uint32_t FIND_ALL = 6u;
        static constexpr uint32_t GET_CATEGORIES = 7u;
        static constexpr uint32_t GET_LABELS = 8u;
        static constexpr uint32_t APPEND = 9u;
        static constexpr uint32_t FIND = 10u;
        static constexpr uint32_t FULL_CATEGORY = 11u;
        static constexpr uint32_t IN_CATEGORY = 12u;
        static constexpr uint32_t KEEP = 13u;
        static constexpr uint32_t SET_PARTIAL_CATEGORY = 14u;
        static constexpr uint32_t COPY = 15u;
        static constexpr uint32_t RESIZE = 16u;
        static constexpr uint32_t HAS_LABEL = 17u;
        static constexpr uint32_t HAS_CATEGORY = 18u;
        static constexpr uint32_t IS_VALID = 19u;
        static constexpr uint32_t FILL_CATEGORY = 20u;
        static constexpr uint32_t REPEAT = 21u;
        static constexpr uint32_t KEEP_EACH = 22u;
        static constexpr uint32_t KEEP_EACHC = 23u;
        static constexpr uint32_t COLLAPSE_CATEGORY = 24u;
        static constexpr uint32_t ONE = 25u;
        static constexpr uint32_t EQUALS = 26u;
        static constexpr uint32_t PARTIAL_CATEGORY = 27u;
        static constexpr uint32_t REMOVE_CATEGORY = 28u;
        static constexpr uint32_t N_CATEGORIES = 29u;
        static constexpr uint32_t N_LABELS = 30u;
        static constexpr uint32_t ASSIGN = 31u;
        static constexpr uint32_t SET_CATEGORIES = 32u;
        static constexpr uint32_t SET_PARTIAL_CATEGORIES = 33u;
        static constexpr uint32_t ASSIGN_PARTIAL = 34u;
        static constexpr uint32_t PRUNE = 35u;
        static constexpr uint32_t COUNT = 36u;
        static constexpr uint32_t TO_NUMERIC_MATRIX = 37u;
        static constexpr uint32_t GET_BUILD_CONFIG = 38u;
        static constexpr uint32_t EMPTY = 39u;
        static constexpr uint32_t PROGENITORS_MATCH = 40u;
        static constexpr uint32_t ADD_CATEGORY = 41u;
        static constexpr uint32_t IN_CATEGORIES = 42u;
        static constexpr uint32_t FROM_CATEGORICAL = 43u;
        //
        static constexpr uint32_t N_OPS = 44u;
    }
}
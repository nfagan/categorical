#include "cat_api.hpp"
#include "cat_opcodes.hpp"
#include <iostream>
#include <array>

namespace util {
    namespace globals {
        const std::unordered_map<std::string, util::u32> op_map({
            {"create",                  util::ops::CREATE},
            {"destroy",                 util::ops::DESTROY},
            {"find_allc",               util::ops::FIND_ALLC},
            {"find_all",                util::ops::FIND_ALL},
            {"set_cat",                 util::ops::SET_CATEGORY},
            {"require_cat",             util::ops::REQUIRE_CATEGORY},
            {"size",                    util::ops::SIZE},
            {"get_labs",                util::ops::GET_LABELS},
            {"get_cats",                util::ops::GET_CATEGORIES},
            {"append",                  util::ops::APPEND},
            {"find",                    util::ops::FIND},
            {"full_cat",                util::ops::FULL_CATEGORY},
            {"in_cat",                  util::ops::IN_CATEGORY},
            {"keep",                    util::ops::KEEP},
            {"set_partial_cat",         util::ops::SET_PARTIAL_CATEGORY},
            {"copy",                    util::ops::COPY},
            {"resize",                  util::ops::RESIZE},
            {"has_lab",                 util::ops::HAS_LABEL},
            {"has_cat",                 util::ops::HAS_CATEGORY},
            {"is_valid",                util::ops::IS_VALID},
            {"fill_cat",                util::ops::FILL_CATEGORY},
            {"repeat",                  util::ops::REPEAT},
            {"keep_each",               util::ops::KEEP_EACH},
            {"keep_eachc",              util::ops::KEEP_EACHC},
            {"collapse_cat",            util::ops::COLLAPSE_CATEGORY},
            {"one",                     util::ops::ONE},
            {"equals",                  util::ops::EQUALS},
            {"partial_cat",             util::ops::PARTIAL_CATEGORY},
            {"rm_cat",                  util::ops::REMOVE_CATEGORY},
            {"n_cats",                  util::ops::N_CATEGORIES},
            {"n_labs",                  util::ops::N_LABELS},
            {"assign",                  util::ops::ASSIGN},
            {"set_cats",                util::ops::SET_CATEGORIES},
            {"set_partial_cats",        util::ops::SET_PARTIAL_CATEGORIES},
            {"assign_partial",          util::ops::ASSIGN_PARTIAL},
            {"prune",                   util::ops::PRUNE},
            {"count",                   util::ops::COUNT},
            {"to_numeric_mat",          util::ops::TO_NUMERIC_MATRIX}
        });
        
        std::array<util::mex_func_t, util::ops::N_OPS> funcs;
        
        bool INITIALIZED = false;
    }
}

void util::init_cat_functions()
{
    using namespace util;
    
    if (globals::INITIALIZED)
    {
        return;
    }
    
    globals::funcs[ops::CREATE] =                   &util::create;
    globals::funcs[ops::DESTROY] =                  &util::destroy;
    globals::funcs[ops::SET_CATEGORY] =             &util::set_category;
    globals::funcs[ops::REQUIRE_CATEGORY] =         &util::require_category;
    globals::funcs[ops::FIND_ALLC] =                &util::find_allc;
    globals::funcs[ops::FIND_ALL] =                 &util::find_all;
    globals::funcs[ops::SIZE] =                     &util::size;
    globals::funcs[ops::GET_CATEGORIES] =           &util::get_categories;
    globals::funcs[ops::GET_LABELS] =               &util::get_labels;
    globals::funcs[ops::APPEND] =                   &util::append;
    globals::funcs[ops::FIND] =                     &util::find;
    globals::funcs[ops::FULL_CATEGORY] =            &util::full_category;
    globals::funcs[ops::IN_CATEGORY] =              &util::in_category;
    globals::funcs[ops::KEEP] =                     &util::keep;
    globals::funcs[ops::SET_PARTIAL_CATEGORY] =     &util::set_partial_category;
    globals::funcs[ops::COPY] =                     &util::copy;
    globals::funcs[ops::RESIZE] =                   &util::resize;
    globals::funcs[ops::HAS_LABEL] =                &util::has_label;
    globals::funcs[ops::HAS_CATEGORY] =             &util::has_category;
    globals::funcs[ops::IS_VALID] =                 &util::is_valid;
    globals::funcs[ops::FILL_CATEGORY] =            &util::fill_category;
    globals::funcs[ops::REPEAT] =                   &util::repeat;
    globals::funcs[ops::KEEP_EACH] =                &util::keep_each;
    globals::funcs[ops::KEEP_EACHC] =               &util::keep_eachc;
    globals::funcs[ops::COLLAPSE_CATEGORY] =        &util::collapse_category;
    globals::funcs[ops::ONE] =                      &util::one;
    globals::funcs[ops::EQUALS] =                   &util::equals;
    globals::funcs[ops::PARTIAL_CATEGORY] =         &util::partial_category;
    globals::funcs[ops::REMOVE_CATEGORY] =          &util::remove_category;
    globals::funcs[ops::N_CATEGORIES] =             &util::n_categories;
    globals::funcs[ops::N_LABELS] =                 &util::n_labels;
    globals::funcs[ops::ASSIGN] =                   &util::assign;
    globals::funcs[ops::SET_CATEGORIES] =           &util::set_categories;
    globals::funcs[ops::SET_PARTIAL_CATEGORIES] =   &util::set_partial_categories;
    globals::funcs[ops::ASSIGN_PARTIAL] =           &util::assign_partial;
    globals::funcs[ops::PRUNE] =                    &util::prune;
    globals::funcs[ops::COUNT] =                    &util::count;
    globals::funcs[ops::TO_NUMERIC_MATRIX] =        &util::to_numeric_matrix;
    
    globals::INITIALIZED = true;
    
    std::cout << std::endl;
    std::cout << "Initialized fcat interface." << std::endl << std::endl;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{   
    char cmd[64];
    
    util::init_cat_functions();
    
    if (nrhs == 0)
    {
        std::cout << std::endl; 
        std::cout << "Try: `help fcat/fcat`" << std::endl << std::endl;
        return;
    }
    
    if (mxGetString(prhs[0], cmd, sizeof(cmd)))
    {
        mexErrMsgIdAndTxt("categorical:main", "Invalid op-code.");
    }
    
    auto op_it = util::globals::op_map.find(std::string(cmd));
    
    if (op_it == util::globals::op_map.end())
    {
        mexErrMsgIdAndTxt("categorical:main", "Invalid op-code.");
    }
    
    util::globals::funcs[op_it->second](nlhs, plhs, nrhs, prhs);
}
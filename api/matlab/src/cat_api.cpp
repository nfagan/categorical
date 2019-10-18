#include "cat_api.hpp"
#include <iostream>
#include <array>

namespace util {
    namespace globals {
        const std::unordered_map<std::string, util::mex_func_t> op_map({
            {"create",                  &util::create},
            {"destroy",                 &util::destroy},
            {"find_allc",               &util::find_allc},
            {"find_all",                &util::find_all},
            {"set_cat",                 &util::set_category},
            {"require_cat",             &util::require_category},
            {"size",                    &util::size},
            {"get_labs",                &util::get_labels},
            {"get_cats",                &util::get_categories},
            {"append",                  &util::append},
            {"find",                    &util::find},
            {"full_cat",                &util::full_category},
            {"in_cat",                  &util::in_category},
            {"keep",                    &util::keep},
            {"set_partial_cat",         &util::set_partial_category},
            {"copy",                    &util::copy},
            {"resize",                  &util::resize},
            {"has_lab",                 &util::has_label},
            {"has_cat",                 &util::has_category},
            {"is_valid",                &util::is_valid},
            {"fill_cat",                &util::fill_category},
            {"repeat",                  &util::repeat},
            {"keep_each",               &util::keep_each},
            {"keep_eachc",              &util::keep_eachc},
            {"collapse_cat",            &util::collapse_category},
            {"one",                     &util::one},
            {"equals",                  &util::equals},
            {"partial_cat",             &util::partial_category},
            {"rm_cat",                  &util::remove_category},
            {"n_cats",                  &util::n_categories},
            {"n_labs",                  &util::n_labels},
            {"assign",                  &util::assign},
            {"set_cats",                &util::set_categories},
            {"set_partial_cats",        &util::set_partial_categories},
            {"assign_partial",          &util::assign_partial},
            {"prune",                   &util::prune},
            {"count",                   &util::count},
            {"to_numeric_mat",          &util::to_numeric_matrix},
            {"get_build_config",        &util::get_build_config},
            {"empty",                   &util::empty},
            {"progenitors_match",       &util::progenitors_match},
            {"add_cat",                 &util::add_category},
            {"in_cats",                 &util::in_categories},
            {"from_categorical",        &util::from_categorical},
            {"replace",                 &util::replace},
            {"merge",                   &util::merge},
            {"remove",                  &util::remove_labels},
            {"rename_cat",              &util::rename_category},
            {"merge_new",               &util::merge_new},
            {"append_one",              &util::append_one},
            {"find_or",                 &util::find_or},
            {"get_uniform_cats",        &util::get_uniform_categories},
            {"find_not",                &util::find_not},
            {"find_none",               &util::find_none},
            {"which_cat",               &util::which_category},
            {"is_uniform_cat",          &util::is_uniform_category},
            {"version",                 &util::get_version},
            {"add_label",               &util::add_label},
            {"union",                   &util::make_set_union}
        });
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{   
    char cmd[64];
    
    if (nrhs == 0)
    {
        std::cout << std::endl; 
        std::cout << "Try: `help fcat/fcat`" << std::endl << std::endl;
        return;
    }
    
    if (mxGetString(prhs[0], cmd, sizeof(cmd)))
    {
        mexErrMsgIdAndTxt("categorical:main", "Expected char op-code.");
    }
    
    auto op_it = util::globals::op_map.find(std::string(cmd));
    
    if (op_it == util::globals::op_map.end())
    {
        mexErrMsgIdAndTxt("categorical:main", "Nonexistent op-code.");
    }
    
    op_it->second(nlhs, plhs, nrhs, prhs);
}
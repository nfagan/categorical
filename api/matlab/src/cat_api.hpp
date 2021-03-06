#include "mex.h"
#include "cat_mex_helpers.hpp"
#include "cat_class_handle.hpp"
#include "categorical.hpp"

#define MEXFUNC(id) \
  void id(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])

namespace util {    
    MEXFUNC(is_valid);
    MEXFUNC(equals);
    MEXFUNC(progenitors_match);
    
    MEXFUNC(create);
    MEXFUNC(destroy);
    MEXFUNC(copy);
    
    MEXFUNC(merge);
    MEXFUNC(append);
    MEXFUNC(append_one);
    MEXFUNC(assign);
    MEXFUNC(prune);
    
    MEXFUNC(replace);
    MEXFUNC(fill_category);
    MEXFUNC(set_category);
    MEXFUNC(set_categories);
    MEXFUNC(require_category);
    MEXFUNC(add_category);
    MEXFUNC(add_label);
    MEXFUNC(collapse_category);
    MEXFUNC(remove_category);
    MEXFUNC(rename_category);
    
    MEXFUNC(full_category);
    MEXFUNC(in_category);
    MEXFUNC(in_categories);
    MEXFUNC(which_category);
    MEXFUNC(is_uniform_category);
    
    MEXFUNC(get_categories);
    MEXFUNC(get_uniform_categories);
    MEXFUNC(get_labels);
    MEXFUNC(has_label);
    MEXFUNC(has_category);
    
    MEXFUNC(one);
    MEXFUNC(empty);
    
    MEXFUNC(remove_labels);
    MEXFUNC(keep_each);
    MEXFUNC(keep_eachc);
    MEXFUNC(keep);
    MEXFUNC(resize);
    MEXFUNC(repeat);
    
    MEXFUNC(size);
    MEXFUNC(n_categories);
    MEXFUNC(n_labels);
    
    MEXFUNC(count);
    MEXFUNC(find);
    MEXFUNC(find_all);
    MEXFUNC(find_allc);
    
    MEXFUNC(to_numeric_matrix);
    MEXFUNC(from_categorical);
    MEXFUNC(set_membership_handler);
    
    MEXFUNC(get_build_config);
    MEXFUNC(get_version);
}
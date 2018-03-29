#include "mex.h"
#include "cat_mex_helpers.hpp"
#include "cat_class_handle.hpp"
#include "categorical.hpp"

#define MEXFUNC(id) \
  void id(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])

namespace util {
    void init_cat_functions();
    
    MEXFUNC(is_valid);
    MEXFUNC(equals);
    MEXFUNC(progenitors_match);
    
    MEXFUNC(create);
    MEXFUNC(destroy);
    MEXFUNC(copy);
    
    MEXFUNC(append);
    MEXFUNC(assign);
    MEXFUNC(assign_partial);
    MEXFUNC(prune);
    
    MEXFUNC(fill_category);
    MEXFUNC(set_category);
    MEXFUNC(set_partial_category);
    MEXFUNC(set_categories);
    MEXFUNC(set_partial_categories);
    MEXFUNC(require_category);
    MEXFUNC(collapse_category);
    MEXFUNC(remove_category);
    
    MEXFUNC(full_category);
    MEXFUNC(partial_category);
    MEXFUNC(in_category);
    
    MEXFUNC(get_categories);
    MEXFUNC(get_labels);
    MEXFUNC(has_label);
    MEXFUNC(has_category);
    
    MEXFUNC(one);
    MEXFUNC(empty);
    
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
    
    MEXFUNC(get_build_config);
}
#include "mex.h"
#include "cat_mex_helpers.hpp"
#include "cat_class_handle.hpp"
#include "categorical.hpp"

namespace util {
    void init_cat_functions();
    
    void is_valid(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    
    void create(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void destroy(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void copy(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    
    void append(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    
    void set_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void set_partial_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void require_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    
    void full_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void in_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    
    void get_categories(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void get_labels(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void has_label(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void has_category(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    
    void keep(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void resize(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    
    void size(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    
    void find(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void find_all(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
    void find_allc(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
}
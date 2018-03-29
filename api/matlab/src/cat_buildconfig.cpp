#include "cat_api.hpp"

void util::get_build_config(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    const char* func_id = "categorical:buildconfig";
    
    const char* fieldnames[2] = { "prune_after_assign", "use_progenitor_ids" };
    
    util::assert_nrhs(nrhs, 1, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    mxArray* conf = mxCreateStructMatrix(1, 1, 2, fieldnames);
    
#ifdef CAT_USE_PROGENITOR_IDS
    mxArray* use_progenitor_ids = mxCreateLogicalScalar(true);
#else
    mxArray* use_progenitor_ids = mxCreateLogicalScalar(false);
#endif
    
#ifdef CAT_PRUNE_AFTER_ASSIGN
    mxArray* prune = mxCreateLogicalScalar(true);
#else
    mxArray* prune = mxCreateLogicalScalar(false);
#endif
    
    mxSetFieldByNumber(conf, 0, 0, prune);
    mxSetFieldByNumber(conf, 0, 1, use_progenitor_ids);
    
    plhs[0] = conf;
}
#include "cat_api.hpp"
#include "cat_version.hpp"

void util::get_version(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    const char* func_id = "categorical:version";
    
    util::assert_nrhs(nrhs, 1, func_id);
    util::assert_nlhs(nlhs, 1, func_id);
    
    const char* fieldnames[4] = { "major", "minor", "patch", "build_id" };
    mxArray* version_info = mxCreateStructMatrix(1, 1, 4, fieldnames);
    
    mxArray* version_id = mxCreateString(util::CATEGORICAL_VERSION_ID);
    
    mxArray* version_major = mxCreateDoubleScalar(double(util::version::Version::major));
    mxArray* version_minor = mxCreateDoubleScalar(double(util::version::Version::minor));
    mxArray* version_patch = mxCreateDoubleScalar(double(util::version::Version::patch));
            
    mxSetFieldByNumber(version_info, 0, 0, version_major);
    mxSetFieldByNumber(version_info, 0, 1, version_minor);
    mxSetFieldByNumber(version_info, 0, 2, version_patch);
    mxSetFieldByNumber(version_info, 0, 3, version_id);
    
    plhs[0] = version_info;
}
%   CAT_API -- Mex interface to categorical library.
%
%     The cat_api mex function is the internal interface to the cpp
%     categorical library, and helps implement the `fcat` Matlab class.
%
%     This function should not ever be called directly; doing so can crash
%     Matlab. Instead, make use of the `fcat` object.
%
%     See also fcat
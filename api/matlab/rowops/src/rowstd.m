%   ROWSTD -- Standard deviation across rows, for each subset of data.
%
%     devs = rowstd( data, I ) returns `devs` across rows of `data` for 
%     each subset of rows identified by an index in `I`. 
%
%     `I` is a cell array of uint64 indices whose values are within 
%     `[1, size(data, 1)]`.
%
%     Output `devs` is an MxN double array where M corresponds to
%     `numel(I)`, such that each row of `devs` is the standard deviation 
%     across rows for the corresponding element of `I`.
%
%     Input `data` must be a 2-dimensional double array.
%
%     See also rowmean, rownanmean, rowop
%
%     IN:
%       - `data` (double)
%       - `I` (cell array of uint64)
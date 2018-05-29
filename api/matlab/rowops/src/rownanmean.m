%   ROWNANMEAN -- Mean across rows, for each subset of data, excluding NaN.
%
%     means = rownanmean( data, I ) returns `means` across rows of `data` 
%     for each subset of rows identified by an index in `I`, excluding NaN.
%     If all values are NaN in a given column, the result for that column 
%     is NaN.
%
%     `I` is a cell array of uint64 indices whose values are within 
%     `[1, size(data, 1)]`.
%
%     Output `means` is an MxN double array where M corresponds to
%     `numel(I)`, such that each row of `means` is the mean across rows for
%     the corresponding element of `I`.
%
%     Input `data` must be a 2-dimensional double array.
%
%     IN:
%       - `data` (double)
%       - `I` (cell array of uint64)
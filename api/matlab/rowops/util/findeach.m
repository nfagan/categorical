function [I, C] = findeach(X, each, varargin)

%   FINDEACH -- Find each unique row.
%
%     I = FINDEACH( X, each ) for the 2D array `X` and vector of column 
%     subscripts `each` returns a cell array of index vectors `I`. Each 
%     element of `I` is a subset of row indices into `X` corresponding to 
%     a unique row of `X(:, each)` columns.
%
%     [I, C] = FINDEACH(...) also returns `C`, an MxN matrix whose ith
%     row is the unique row corresponding to `X(I{i}, each)`. The j-th
%     column of `C` is an element taken from the `each(j)` column of `X`.
%
%     [...] = FINDEACH(..., 'mask', mask) finds the unique rows of
%     `X(mask, each)` and returns indices that are a subset of `mask`.
%
%     See also rowsets, unique, fcat/findall

[I, ~, C] = rowsets( 1, X, each, varargin{:} );

% if ( ~isempty(C) )
  C = vertcat( C{:} );
% end

end
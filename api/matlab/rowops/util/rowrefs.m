function d = rowrefs(data, I, un)

%   ROWREFS -- Row-reference data for indexed subsets.
%
%     B = rowrefs( A, I ); calls `rowref` separately for each subset of
%     rows of `A` identified by each index in `I`. `B` is a cell array
%     whose elements are arrays of row-referenced subsets of `A`.
%
%     B = rowrefs( A, I, UNIFORM ) specifies whether the output of the
%     indexing expression A(i, ...) is uniform across indices in `I`. If
%     true, `B` is of the same class as `A`. Otherwise, `B` is a cell
%     array. Default is false.
%
%     See also rowref

if ( nargin < 3 ), un = false; end
d = rowop( data, I, @(x) x, un );

end
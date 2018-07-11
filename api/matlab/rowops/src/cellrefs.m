function out = cellrefs(data, I, ref_func)

%   CELLREFS -- Reference data from cell array of index vectors.
%
%     B = cellrefs( data, I ); returns `B`, a cell array the same size as
%     `I` whose elements are the elements of `data` identified by each
%     index in `I`.
%
%     B = cellrefs( ..., ref_func ) uses `ref_func` to obtain subsets of
%     `data`, instead of linear indices. `ref_func` is a handle to a
%     function that accepts two inputs: `data`, and an `index`, a uint64,
%     double, or logical index vector. By default, `ref_func` is equivalent
%     to `@(data, index) data(index)`
%
%     See also fcat, rowref
%
%     IN:
%       - `data` (/T/)
%       - `I` (cell array of uint64, logical, double)
%       - `ref_func` (function_handle) |OPTIONAL|
%     OUT:
%       - `out` (cell array of T)

if ( nargin < 3 )
  ref_func = @(x, y) x(y);
end

out = cell( size(I) );

for i = 1:numel(out)
  out{i} = ref_func( data, I{i} );
end

end
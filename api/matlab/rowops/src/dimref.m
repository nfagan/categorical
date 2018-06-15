function d = dimref(data, I, dim)

%   DIMREF -- Subscript reference for dimension, retaining other dimensions.
%
%     B = dimref( A, 1:10, 2 ) is the same as A(:, 1:10) when A is a matrix. 
%     B = dimref( A, 1:10, 2 ) is the same as A(:, 1:10, :) when A is a 3-d
%     array.
%
%     In this way, dimref indexes a subset of data for a given dimension,
%     retaining all elements along the remaining dimensions.
%
%     See also rowref
%
%     IN:
%       - `data` (/T/)
%       - `I` (double, uint64, logical)
%       - `dim` (double)
%     OUT:
%       - `d` (/T/)

assert( isscalar(dim) && dim > 0 && dim <= ndims(data) ...
  , 'Dimension must be an integer scalar within indexing range.' ); 
indices = repmat( {':'}, 1, ndims(data) );
indices{dim} = I;
d = data(indices{:});

end
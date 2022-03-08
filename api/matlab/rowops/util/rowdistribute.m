function d = rowdistribute(d, I, m)

%   ROWDISTRIBUTE -- Distribute rows into larger array.
%
%     x = ROWDISTRIBUTE( x, I, m ) distributes rows of `m` into `x` at 
%     indices given by `I`. `I` is a cell array of index vectors with one 
%     element for each row of `m`. For one element of `I`, one row of `m` 
%     is distributed into `x`, e.g., x(I{i}, :) = m(i, :), for the i-th 
%     element.
%
%     See also rowref, rowifun

assert( numel(I) == size(m, 1), 'Indices do not correspond to source matrix.' );
assert( isequal(notsize(d, 1), notsize(m, 1)) ...
  , 'Destination and source data must have the same size apart from the number of rows.' );

cs = colons( ndims(d)-1 );
one = ones( 1, ndims(d)-1 );

for i = 1:numel(I)
  d(I{i}, cs{:}) = repmat( m(i, cs{:}), [numel(I{i}), one] );
end

end
function ind = flatten_indices(rows, I)

%   FLATTEN_INDICES -- Assign cell array of indices to single vector.
%
%     indices = flatten_indices( rows, I ); for a numeric scalar `rows` and
%     a cell vector of numeric linear indices `I` returns a column vector 
%     `indices` with `rows` rows whose elements represent the contents of
%     `I` in a "flattened" way. Specifically, if `I` is an Mx1 cell array
%     of non-empty index vectors, then `indices` will contain integers in 
%     the range 1:M; for each index `I{i}`, `unique( indices(I{i}) ) == i`.
%
%     Elements of `indices` that are not assigned a value in `I` are 0. In
%     general, it is expected that the indices in `I` are unique across
%     elements of `I`; duplicate indices will be assigned the largest `i`.
%
%     EX //
%
%     inds = flatten_indices( 5, {1, 2:3, 4:5} )
%
%     % First index vector sets overlapping(1:3) = 1, but the second index
%     % vector sets overlapping(2) = 2
%     overlapping = flatten_indices( 3, {1:3, 2} )
%
%     % `missing` is a 5x1 column vector, but only elements 3 and 4 have
%     % defined indices; other elements are 0.
%     missing = flatten_indices( 5, {3, 4} )
%
%     f = fcat.example();
%     d = fcat.example( 'smalldata' );
%     I = findall( f, 'dose' );
%
%     inds = flatten_indices( rows(f), I );
%
%     rowop_mean = rowop( d, I, @mean );
%     accum_mean = accumarray( inds, d, [], @mean );
%
%     assert( isequaln(rowop_mean, accum_mean) );
%
%     See also fcat/findall, rowop, accumarray

ind = zeros( rows, 1 );

for i = 1:numel(I)
  ind(I{i}) = i;
end

end
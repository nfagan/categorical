function ps = ranksum_matrix(m, ia, ib)

%   RANKSUM_MATRIX -- Ranksum tests separately for subsets and columns.
%
%     ps = ranksum_matrix( m, ia, ib ); for the matrix `m` and cell arrays
%     of index vectors `ia` and `ib` performs a ranksum test between
%     indexed subsets of each column of `m`. `ia` and `ib` have the same
%     number of elements, and the ith elements of `ia` and `ib` form sets
%     `m(ia{i}, :)` and `m(ib{i}, :)` whose columns are ranksum-tested.
%
%     `ps` is an MxN matrix with one row for each element of `ia` and one 
%     column for each column of `m`.
%
%     See also fcat/findall

assert( numel(ia) == numel(ib) );
ps = nan( numel(ia), size(m, 2) );

ir = numel( ia );
ic = size( m, 2 );

parfor i = 1:ir
  if ( ~isempty(ia{i}) && ~isempty(ib{i}) )
    for j = 1:ic
      ps(i, j) = ranksum( m(ia{i}, j), m(ib{i}, j) );
    end
  end
end

end
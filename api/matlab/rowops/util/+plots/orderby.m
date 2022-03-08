function ord = orderby(C, ls, mask)

%   ORDERBY -- Order rows of labels by substrings.
%
%     ord = ORDERBY( C, ls ) for the array `C` and string-like array `ls` 
%     produces a vector `ord` that is a permutation of the rows of `C` such 
%     that rows containing a substring in `ls` are sorted in order of the
%     substrings' appearences in `ls`. Elements of `C` must be string-like,
%     convertible to string, or a cell array or table of such values.
%
%     ord = ORDERBY( ..., ord ) operates on the permuted rows of C, that is
%     on `C(ord, :)` and returns an ordering that is a permutation of
%     `ord`.
%
%     //  EX
%     plots.orderby( {'aa'; 'bb'; 'cc'}, 'b' ) % [2, 1, 3]
%
%     See also plots.cellstr_join, plots.contains

if ( nargin < 3 )
  mask = 1:size(C, 1);
end

ls = cellstr( ls );

matches = inf( size(C) );
C = C(mask, :);

for i = 1:numel(ls)
  match = plots.contains( C, ls{i} );
  matches(match) = i;
end

to_sort = inf( rows(C), 1 );
for i = 1:rows(C)
  ind = find( ~isinf(matches(i, :)), 1 );
  if ( ~isempty(ind) )
    to_sort(i) = matches(i, ind);
  end
end

[~, ord] = sort( to_sort );
ord = mask(ord);

end
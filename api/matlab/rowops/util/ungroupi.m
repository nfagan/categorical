function [g, v] = ungroupi(I)

%   UNGROUPI -- Create grouping vector from sets of indices.
%
%     gi = UNGROUPI( I ); for the cell array of numeric indices `I` returns
%     a grouping vector `gi` whose length is the maximum value across all 
%     indices in `I`. `gi` is equal to 1 at indices given by I{1}, and 2 at
%     indices given by I{2}, and so on. `gi` is zero for non-indexed
%     elements, that is, for elements not referred to by an index in `I`.
%
%     [gi, vi] = UNGROUPI( I ); alternatively returns `gi` after selecting
%     only non-zero entries of it, so that it is a valid grouping vector,
%     and returns a logical vector `vi` indicating those selected (i.e.,
%     non-zero) entries.
%
%     See also groupi, unique, intersect, categorical, accumarray

mxi = max( cellfun(@max, I) );
g = zeros( mxi, 1 );
for i = 1:numel(I)
  g(I{i}) = i;
end

if ( nargout > 1 )
  v = g ~= 0;
  g = g(v);
end

end
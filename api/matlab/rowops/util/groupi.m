function o = groupi(subs)

%   GROUPI -- Create groups of indices of alike subscripts.
%
%     groups = groupi( subs ); for the numeric integer-valued array `subs`
%     creates `groups` of indices of the distinct values of `subs`.
%     `groups` is a cell array. The i-th element of `groups` contains the
%     set of linear indices into `subs` for which `subs == i`.
%
%     EX //
%
%     [c, cats] = categorical( fcat.example() );
%     [c2, ~, ic] = unique( c(:, 2:3), 'rows' );
%     % each element of `groups` is the set of indices into `c`
%     % corresponding to a row in `c2`.
%     groups = groupi( ic );
%
%     See also unique, intersect, categorical, accumarray

if ( isempty(subs) )
  o = {};
else
  o = accumarray( subs(:), 1:numel(subs), [], @(x) {x} );
end

end
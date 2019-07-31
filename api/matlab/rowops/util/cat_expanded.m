function x = cat_expanded(dim, c)

%   CAT_EXPANDED -- Concatenate expanded list of arrays.
%
%     b = cat_expanded( dim, a ); concatenates the cell array of arrays `a`
%     along the dimension `dim`.
%
%     It is the same as `cat( dim, c{:} )`.
%
%     See also cat, lists

x = cat( dim, c{:} );

end
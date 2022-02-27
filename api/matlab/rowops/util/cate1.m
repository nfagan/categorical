function Y = cate1(X)

%   CATE1 -- Vertically concatenate list-expanded cell array.
%
%     CATE1( X ) for the cell array `X` is the same as cat(1, X{:}).
%
%     See also cat, vertcat, cell2mat

Y = cat( 1, X{:} );

end
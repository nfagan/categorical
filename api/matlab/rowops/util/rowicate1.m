function y = rowicate1(I, x, un)

%   ROWICATE1-- Vertically concatenate list-expanded indexed subsets.
%
%     y = ROWICATE1( I, x ) for the cell array of index vectors `I` and
%     cell array of arbitrary data `x` returns a cell array the same size
%     as `I`. Each element of `y` is vertcat( x{I{i}} ) for the i-th 
%     element of `I`.
%
%     See also rowifun, cate1

if ( nargin < 3 )
  un = 0;
end

y = rowifun( @cate1, I, x, 'un', un );

end
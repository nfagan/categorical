function to = rowasgn(to, inds, data)

%   ROWASGN -- Subscript assignment to rows, completing other dimensions.
%
%     B = rowasgn( A, 11:20, eye(10) ) is equivalent to 
%     A(11:20, :) = eye( 10 ) when A is a matrix.
%
%     B = rowasgn( A, 1:2, zeros(2, 2, 2) ) is equivalent to 
%     A(1:2, :, :) = zeros( 2, 2, 2 ) when A is a 3-d array.
%
%     In this way, rowasgn assigns to a subset of rows for a given index
%     vector, and uses colons (':') for the remaining dimensions.
%
%     See also rowref, fcat
%
%     IN:
%       - `data` (/T/)
%       - `I` (double, uint64, logical)
%     OUT:
%       - `d` (/T/)

colons = repmat( {':'}, 1, ndims(data)-1 );
to(inds, colons{:}) = data;

end
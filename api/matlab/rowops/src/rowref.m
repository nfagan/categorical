function d = rowref(data, I)

%   ROWREF -- Subscript reference by rows, retaining other dimensions.
%
%     B = rowref( A, 1:10 ) is the same as A(1:10, :) when A is a matrix. 
%     B = rowref( A, 1:10 ) is the same as A(1:10, :, :) when A is a 3-d
%     array.
%
%     In this way, rowref retains a subset of rows for a given index
%     vector, and all elements along the remaining dimensions.
%
%     See also rowasgn, fcat
%
%     IN:
%       - `data` (/T/)
%       - `I` (double, uint64, logical)
%     OUT:
%       - `d` (/T/)

colons = repmat( {':'}, 1, ndims(data)-1 );
d = data(I, colons{:});

end
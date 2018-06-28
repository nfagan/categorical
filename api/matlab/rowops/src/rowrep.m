function data = rowrep(data, N)

%   ROWREP -- Replicate and tile array along first dimension.
%
%     B = rowrep( A, 100 ), where A is a matrix, is the same as 
%     repmat( A, 100, 1 ).
%
%     B = rowrep( A, 100 ), where A is an n-d array, is the same as
%     repmat( A, 100, 1, 1, ... ).
%
%     See also rowref, columnize
%
%     IN:
%       - `data` (/T/)
%       - `N` (double)
%     OUT:
%       - `data` (/T/)

rest = ones( 1, ndims(data)-1 );
szs = [ N, rest ];
data = repmat( data, szs );

end
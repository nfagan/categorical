function mask = rowmask(data)

%   ROWMASK -- Create a row-vector mask, 1:rows(X).
%
%     mask = rowmask( A ); creates an Mx1 row-vector, where M is equal to
%     `size( A, 1 )`.
%
%     See also fcat, fcat/find, rows
%
%     IN:
%       - `data` (/any/)
%     OUT:
%       - `mask` (double)

mask = (1:rows(data))';

end
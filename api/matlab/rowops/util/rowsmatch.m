function tf = rowsmatch(a, b)

%   ROWSMATCH -- True if arrays have the same number of rows.
%
%     See also rows, joinsize
%
%     IN:
%       - `a` (/any/)
%       - `b` (/any/)
%     OUT:
%       - `tf` (logical)

tf = rows( a ) == rows( b );

end
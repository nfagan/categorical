function B = columnize(A)

%   COLUMNIZE -- Make row-vector.
%
%     B = columnize(A) is the same as A(:).
%
%     IN:
%       - `A` (/T/)
%     OUT:
%       - `B` (/T/)

B = reshape( A, [], 1 );
end
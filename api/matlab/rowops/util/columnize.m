function B = columnize(A)

%   COLUMNIZE -- Make column-vector.
%
%     B = columnize(A) is the same as A(:).
%
%     See also reshape, rowop

B = reshape( A, [], 1 );
end
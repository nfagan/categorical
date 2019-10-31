function s = joinsize(A, B)

%   JOINSIZE -- Get size from rows of A and remaining dimensions of B.
%
%     s = joinsize( A, B ) returns a size vector `s` whose first element
%     is the number of rows of `A`, and whose remaining elements contain
%     the size of `B` beyond the first dimension.
%
%     See also notsize, rows

s = [ rows(A), notsize(B, 1) ];

end
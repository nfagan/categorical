function s = rowmsg(a, b)

%   ROWMSG -- Get a formatted error message for inputs with mismatching rows.
%
%     Note that this function does not actually check whether inputs have
%     matching rows.
%
%     See also rows, rowsmatch
%
%     IN:
%       - `a` (/any/)
%       - `b` (/any/)
%     OUT:
%       - `s` (char)

s = sprintf( 'Inputs have mismatching rows. A has %d row(s); B has %d.' ...
  , rows(a), rows(b) );

end
function s = rowmsg(a, b, A, B)

%   ROWMSG -- Get a formatted error message for inputs with mismatching rows.
%
%     Note that this function does not actually check whether inputs have
%     matching rows.
%
%     See also rows, rowsmatch

if ( nargin < 4 ), B = 'B'; end
if ( nargin < 3 ), A = 'A'; end

s = sprintf( 'Inputs have mismatching rows. %s has %d row(s); %s has %d.' ...
  , A, rows(a), B, rows(b) );

end
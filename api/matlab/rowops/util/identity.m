% @T import mt.base
% @T :: given <T> [T] = (T)
function x = identity(x)

% IDENTITY -- Function that returns its input.
%
%   identity( x ) is `x` for all inputs.

narginchk( 1, 1 );
end
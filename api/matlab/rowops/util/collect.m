function a = collect(n, f)

%   COLLECT -- Collect outputs from function call into one cell array.
%
%     c = collect( n, f ) calls `f()`, requesting `n` outputs from it. The 
%     outputs are collected into a single cell array `c`.
%
%     `f` is a function_handle and `n` is an integer-valued scalar >= 0.
%
%     See also splat, conditional, attempt

validateattributes( n, {'numeric'}, {'integer', 'nonnegative', 'scalar'} ...
  , mfilename, 'n' );
validateattributes( f, {'function_handle'}, {}, mfilename, 'f' );
a = {};
[a{1:n}] = f();

end
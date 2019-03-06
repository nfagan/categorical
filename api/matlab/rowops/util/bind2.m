function bound = bind2(func, varargin)

%   BIND2 -- Bind arguments to function to create a 2-argument function.
%
%     bound = bind2( func, input1, input2, input3 ); creates a function
%     `bound` that, when applied to two arguments  `x` and `y`, will 
%     include those arguments, as well as additional arguments `input1`, 
%     `input2`, ...
%
%     See also pipe, bind1

validateattributes( func, {'function_handle'}, {'scalar'}, mfilename, 'func' );
bound = @(x, y) func( x, y, varargin{:} );

end
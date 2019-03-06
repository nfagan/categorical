function bound = bind1(func, varargin)

%   BIND1 -- Bind arguments to function to create a 1-argument function.
%
%     bound = bind1( func, input1, input2, ... input_n ); creates a function
%     `bound` that, when applied to a single argument, will include
%     that argument, as well as additional arguments `input1`, `input2`, ...
%
%     EXAMPLE //
%
%     bound_sum = bind1( @sum, 2 );
%     values = rand( 10 );
%     bound_result = bound_sum( values );
%
%     assert( isequaln(bound_result, sum(values, 2)) );
%
%     See also pipe, bind2

validateattributes( func, {'function_handle'}, {'scalar'}, mfilename, 'func' );
bound = @(x) func( x, varargin{:} );

end
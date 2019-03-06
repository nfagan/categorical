function value = pipe(value, varargin)

%   PIPE -- Apply functions to argument, in left-to-right order.
%
%     result = pipe( value, func1, func2, ..., func_n ); where `func1`, ...
%     `func_n` are function handles, and `value` is any type, applies those 
%     functions, in order, to `value`. The output of each function (i) is 
%     the input to the next function (i+1); the output of the last
%     function is `result`.
%
%     EXAMPLE //
%
%     values = rand( 10, 1 );
%     result = pipe( values, @sort, @flip, @sum );
%
%     assert( isequal(result, sum(flip(sort(values)))) );
%
%     See also function_handle, bind1

narginchk( 1, Inf );
n_args = numel( varargin );

for i = 1:n_args
  func = varargin{i};
  
  if ( ~isa(func, 'function_handle') )
    error( 'Inputs beyond the first must be function_handle; was "%s".', class(func) );
  end
  
  value = func( value );
end

end
function varargout = splat(f, arg)

%   SPLAT -- Pass expanded list of arguments to function.
%
%     y = splat( f, arg ) for function handles `f` and `arg` calls arg() to 
%     produce a temporary cell array (i.e., `arg` must return a cell
%     array). The elements of this array are passed via list expansion to
%     `f` and `y` is the output, i.e., y = f( c{:} ); where c = arg().
%
%     [out1, out2, ...] = splat( f, arg ) obtains multiple outputs from
%     the call to `f`.
%
%     The intent of `splat` is to support list expansion in expressions
%     where normally an additional temporary assignment statement would
%     need to be introduced.
%
%     //  EX
%     % Collect arguments to `plot` into a cell array: 
%     c = {1, 2, 'k*'};
%     % Call `plot` by expanding the argument list `c`
%     plot( c{:} );
%
%     % Now imagine `f` is a function which returns an argument list:
%     f = @() {1, 2, 'k*'};
%     % The line below is an error because `f` returns a cell array, which
%     % `plot` does not accept. There's no way to expand the result of `f`
%     % without introducing an additional temporary variable.
%     % plot( f() )
%     % `splat` gets around this limitation by expanding ("splatting") the 
%     % output of `f` into `plot`.
%     splat( @plot, f );
%
%     % Another example: initialize variables from the elements of an
%     % argument list:
%     [x, y, z] = splat( @deal, f )
%
%     See also lists, collect, conditional, attempt

validateattributes( f, {'function_handle'}, {}, mfilename, 'f' );
validateattributes( arg, {'function_handle'}, {}, mfilename, 'arg' );

x = arg();

if ( ~iscell(x) )
  error( ['The argument function ("%s") must return a cell array;' ...
    , ' instead it returned a value of type "%s".'] ...
    , func2str(arg), class(x) );
end

[varargout{1:nargout}] = f( x{:} );

end
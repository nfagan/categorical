function varargout = guard_empty(X, func)

%   GUARD_EMPTY -- Call function with input if input is nonempty.
%
%     Y = guard_empty( X, func ) calls `func(X)` and returns the result in 
%     `Y`, so long as `X` is nonempty. If `X` is empty, `func` is not 
%     called, and `Y` is an empty array ([]).
%
%     [out1, out2] = guard_empty(...) works as above, but returns multiple 
%     outputs from `func`. If `X` is empty, each requested output is an 
%     empty array ([]).
%
%     See also deal

validateattributes( func, {'function_handle'}, {}, mfilename, 'func' );

if ( isempty(X) )
  [varargout{1:nargout}] = deal( [] );
else
  [varargout{1:nargout}] = func( X );
end

end